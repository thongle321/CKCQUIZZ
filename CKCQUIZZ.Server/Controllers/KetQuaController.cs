using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using CKCQUIZZ.Server.Models;
using CKCQUIZZ.Server.Viewmodels.KetQua;
using System.Security.Claims;

namespace CKCQUIZZ.Server.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class KetQuaController : ControllerBase
    {
        private readonly CkcquizzContext _context;

        public KetQuaController(CkcquizzContext context)
        {
            _context = context;
        }

        /// <summary>
        /// Lấy ID của người dùng hiện tại từ JWT token
        /// </summary>
        private string? GetCurrentUserId()
        {
            return User.FindFirst(ClaimTypes.NameIdentifier)?.Value;
        }

        /// <summary>
        /// Cập nhật điểm số cho sinh viên
        /// </summary>
        [HttpPut("update-score")]
        public async Task<IActionResult> UpdateScore([FromBody] UpdateScoreRequestDto request)
        {
            try
            {
                // Tìm hoặc tạo KetQua record
                var ketQua = await _context.KetQuas
                    .FirstOrDefaultAsync(kq => kq.Made == request.ExamId && kq.Manguoidung == request.StudentId);

                if (ketQua == null)
                {
                    // Tạo mới KetQua nếu chưa có
                    ketQua = new KetQua
                    {
                        Made = request.ExamId,
                        Manguoidung = request.StudentId,
                        Diemthi = request.NewScore,
                        Thoigianvaothi = DateTime.UtcNow,
                        Socaudung = 0,
                        Thoigianlambai = 0
                    };
                    _context.KetQuas.Add(ketQua);
                }
                else
                {
                    // Cập nhật điểm cho KetQua đã có
                    ketQua.Diemthi = request.NewScore;
                    _context.KetQuas.Update(ketQua);
                }

                await _context.SaveChangesAsync();

                return Ok(new UpdateScoreResponseDto
                {
                    Success = true,
                    Message = $"Cập nhật điểm thành công: {request.NewScore:F1}",
                    KetQuaId = ketQua.Makq,
                    NewScore = request.NewScore
                });
            }
            catch (Exception ex)
            {
                return BadRequest(new UpdateScoreResponseDto
                {
                    Success = false,
                    Message = $"Lỗi khi cập nhật điểm: {ex.Message}"
                });
            }
        }

        /// <summary>
        /// Tìm ketQuaId theo examId và studentId
        /// </summary>
        [HttpGet("find-by-exam-student/{examId}/{studentId}")]
        public async Task<IActionResult> FindKetQuaId(int examId, string studentId)
        {
            try
            {
                var ketQua = await _context.KetQuas
                    .AsNoTracking()
                    .FirstOrDefaultAsync(kq => kq.Made == examId && kq.Manguoidung == studentId);

                if (ketQua == null)
                {
                    return NotFound(new FindKetQuaResponseDto
                    {
                        Success = false,
                        Message = "Không tìm thấy kết quả thi cho sinh viên này"
                    });
                }

                return Ok(new FindKetQuaResponseDto
                {
                    Success = true,
                    Message = "Tìm thấy kết quả thi",
                    KetQuaId = ketQua.Makq,
                    ExamId = ketQua.Made,
                    StudentId = ketQua.Manguoidung,
                    Score = ketQua.Diemthi
                });
            }
            catch (Exception ex)
            {
                return BadRequest(new FindKetQuaResponseDto
                {
                    Success = false,
                    Message = $"Lỗi khi tìm kiếm: {ex.Message}"
                });
            }
        }

        /// <summary>
        /// Lấy chi tiết kết quả bài thi của sinh viên cho giáo viên
        /// </summary>
        [HttpGet("teacher/student-result/{examId}/{studentId}")]
        public async Task<IActionResult> GetStudentExamResultForTeacher(int examId, string studentId)
        {
            try
            {
                var teacherId = GetCurrentUserId();
                if (string.IsNullOrEmpty(teacherId))
                {
                    return Unauthorized("Không thể xác thực giáo viên.");
                }

                // Kiểm tra xem đề thi có phải do giáo viên này tạo không
                var deThi = await _context.DeThis
                    .AsNoTracking()
                    .FirstOrDefaultAsync(d => d.Made == examId && d.Nguoitao == teacherId);

                if (deThi == null)
                {
                    return Forbid("Bạn chỉ có thể xem kết quả của đề thi do chính mình tạo.");
                }

                // Tìm kết quả thi của sinh viên
                var ketQua = await _context.KetQuas
                    .AsNoTracking()
                    .Include(kq => kq.MadeNavigation)
                        .ThenInclude(d => d.ChiTietDeThis)
                            .ThenInclude(ct => ct.MacauhoiNavigation)
                                .ThenInclude(ch => ch.CauTraLois)
                    .Include(kq => kq.ChiTietKetQuas)
                    .FirstOrDefaultAsync(kq => kq.Made == examId && kq.Manguoidung == studentId);

                if (ketQua == null)
                {
                    return NotFound("Không tìm thấy kết quả thi cho sinh viên này.");
                }

                // Lấy thông tin sinh viên
                var sinhVien = await _context.NguoiDungs
                    .AsNoTracking()
                    .FirstOrDefaultAsync(nd => nd.Id == studentId);

                // Tạo response với chi tiết câu hỏi và đáp án
                var cauHois = new List<object>();

                foreach (var chiTietDeThi in ketQua.MadeNavigation.ChiTietDeThis.OrderBy(ct => ct.Thutu ?? ct.Macauhoi))
                {
                    var cauHoi = chiTietDeThi.MacauhoiNavigation;
                    var chiTietKetQua = ketQua.ChiTietKetQuas.FirstOrDefault(ct => ct.Macauhoi == cauHoi.Macauhoi);

                    // Tìm đáp án đúng
                    var dapAnDung = cauHoi.CauTraLois.FirstOrDefault(ctl => ctl.Dapan == true);

                    // Tìm đáp án sinh viên đã chọn (cần lấy từ ChiTietTraLoiSinhVien)
                    var dapAnSinhVien = await _context.ChiTietTraLoiSinhViens
                        .Include(ct => ct.MacautlNavigation)
                        .FirstOrDefaultAsync(ct => ct.Makq == ketQua.Makq && ct.Macauhoi == cauHoi.Macauhoi);

                    var isCorrect = chiTietKetQua?.Diemketqua > 0;

                    // Tạo tên độ khó dễ hiểu
                    string doKhoText = cauHoi.Dokho switch
                    {
                        1 => "Dễ",
                        2 => "Trung bình",
                        3 => "Khó",
                        _ => "Không xác định"
                    };

                    cauHois.Add(new
                    {
                        macauhoi = cauHoi.Macauhoi,
                        noiDung = cauHoi.Noidung,
                        loaiCauHoi = cauHoi.Loaicauhoi,
                        doKho = doKhoText,
                        hinhAnhUrl = cauHoi.Hinhanhurl,
                        studentAnswer = dapAnSinhVien?.MacautlNavigation?.Noidungtl ?? dapAnSinhVien?.Dapantuluansv ?? "Chưa trả lời",
                        correctAnswer = dapAnDung?.Noidungtl ?? "N/A",
                        isCorrect = isCorrect,
                        diem = chiTietKetQua?.Diemketqua ?? 0
                    });
                }

                var response = new
                {
                    ketQuaId = ketQua.Makq,
                    examId = ketQua.Made,
                    studentId = ketQua.Manguoidung,
                    studentName = sinhVien?.Hoten ?? "N/A",
                    diem = ketQua.Diemthi ?? 0,
                    soCauDung = ketQua.Socaudung ?? 0,
                    tongSoCau = ketQua.MadeNavigation.ChiTietDeThis.Count,
                    thoiGianLamBai = ketQua.Thoigianlambai != null ? Math.Round((double)ketQua.Thoigianlambai / 60, 1) : 0,
                    thoiGianVaoThi = ketQua.Thoigianvaothi,
                    trangThai = ketQua.Diemthi.HasValue ? "Đã nộp" : "Chưa nộp",
                    cauHois = cauHois,
                    examInfo = new
                    {
                        made = deThi.Made,
                        tende = deThi.Tende,
                        monthi = deThi.Monthi
                    }
                };

                return Ok(response);
            }
            catch (Exception ex)
            {
                return StatusCode(500, $"Lỗi server khi lấy chi tiết kết quả: {ex.Message}");
            }
        }
    }
}
