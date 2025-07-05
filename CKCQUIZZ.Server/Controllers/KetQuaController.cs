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

        private string GetCurrentUserId()
        {
            return User.FindFirstValue(ClaimTypes.NameIdentifier)
                ?? throw new UnauthorizedAccessException("Không thể xác định người dùng. Vui lòng đăng nhập lại.");
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
    }
}
