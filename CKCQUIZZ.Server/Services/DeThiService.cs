// Services/DeThiService.cs
using CKCQUIZZ.Server.Data;
using CKCQUIZZ.Server.Interfaces;
using CKCQUIZZ.Server.Models;
using CKCQUIZZ.Server.Viewmodels.DeThi;
using Microsoft.EntityFrameworkCore;
using System.Security.Claims;

namespace CKCQUIZZ.Server.Services
{
    public class DeThiService : IDeThiService
    {
        private readonly CkcquizzContext _context;
        private readonly IHttpContextAccessor _httpContextAccessor;
        public DeThiService(CkcquizzContext context, IHttpContextAccessor httpContextAccessor)
        {
            _context = context;
            _httpContextAccessor = httpContextAccessor;
        }

        // READ ALL
        public async Task<List<DeThiViewModel>> GetAllAsync()
        {
            var deThis = await _context.DeThis
                .Include(d => d.Malops)
                .Include(d => d.Malops) // Nạp danh sách các lớp được gán
                .OrderByDescending(d => d.Thoigiantao)
                .ToListAsync();

            var viewModels = deThis.Select(d => new DeThiViewModel
            {
                Made = d.Made,
                Tende = d.Tende,
                Thoigianbatdau = d.Thoigiantbatdau ?? DateTime.MinValue, // Giả định không null
                Thoigianketthuc = d.Thoigianketthuc ?? DateTime.MinValue,
                Monthi = d.Monthi??0,
                GiaoCho = d.Malops.Any() ? string.Join(", ", d.Malops.Select(l => l.Tenlop)) : "Chưa giao",
                Trangthai = d.Trangthai ?? false
            }).ToList();

            return viewModels;
        }

        // READ ALL BY TEACHER - Chỉ lấy đề thi của giảng viên hiện tại
        public async Task<List<DeThiViewModel>> GetAllByTeacherAsync(string teacherId)
        {
            // Debug: Log để kiểm tra
            Console.WriteLine($"🔍 GetAllByTeacherAsync called with teacherId: {teacherId}");

            var allDeThis = await _context.DeThis
                .Include(d => d.Malops)
                .ToListAsync();

            Console.WriteLine($"📊 Total exams in database: {allDeThis.Count}");
            foreach (var exam in allDeThis)
            {
                Console.WriteLine($"   - Exam ID: {exam.Made}, Title: {exam.Tende}, Creator: {exam.Nguoitao}");
            }

            var deThis = allDeThis
                .Where(d => d.Nguoitao == teacherId) // Filter theo giảng viên tạo
                .OrderByDescending(d => d.Thoigiantao)
                .ToList();

            Console.WriteLine($"✅ Filtered exams for {teacherId}: {deThis.Count}");

            var viewModels = deThis.Select(d => new DeThiViewModel
            {
                Made = d.Made,
                Tende = d.Tende,
                Thoigianbatdau = d.Thoigiantbatdau ?? DateTime.MinValue,
                Thoigianketthuc = d.Thoigianketthuc ?? DateTime.MinValue,
                Monthi = d.Monthi ?? 0,
                GiaoCho = d.Malops.Any() ? string.Join(", ", d.Malops.Select(l => l.Tenlop)) : "Chưa giao",
                Trangthai = d.Trangthai ?? false
            }).ToList();

            return viewModels;
        }

        // READ ONE
        public async Task<DeThiDetailViewModel> GetByIdAsync(int id)
        {
            var deThi = await _context.DeThis
                .Include(d => d.Malops)
                .Include(d => d.ChiTietDeThis).ThenInclude(ct => ct.MacauhoiNavigation)
                .FirstOrDefaultAsync(d => d.Made == id);

            if (deThi == null) return null;

            return new DeThiDetailViewModel
            {
                Made = deThi.Made,
                Tende = deThi.Tende,
                Monthi = deThi.Monthi,
                Thoigianthi = deThi.Thoigianthi ?? 0,
                Thoigiantbatdau = deThi.Thoigiantbatdau ?? DateTime.MinValue,
                Thoigianketthuc = deThi.Thoigianketthuc ?? DateTime.MinValue,
                Xemdiemthi = deThi.Xemdiemthi ?? false,
                Hienthibailam = deThi.Hienthibailam ?? false,
                Xemdapan = deThi.Xemdapan ?? false,
                Troncauhoi = deThi.Troncauhoi ?? false,
                Loaide = deThi.Loaide ?? 1,
                Socaude = deThi.Socaude ?? 0,
                Socautb = deThi.Socautb ?? 0,
                Socaukho = deThi.Socaukho ?? 0,
                Malops = deThi.Malops.Select(l => l.Malop).ToList(),
                Machuongs = deThi.ChiTietDeThis.Select(ct => ct.MacauhoiNavigation.Machuong).Distinct().ToList()
            };
        }

        // CREATE (Code của bạn đã tốt, tôi chỉ tinh chỉnh một chút)
        public async Task<DeThiViewModel> CreateAsync(DeThiCreateRequest request)
        {
            var creatorId = _httpContextAccessor.HttpContext?.User?.FindFirstValue(ClaimTypes.NameIdentifier);
            if (string.IsNullOrEmpty(creatorId))
            {
                // Ném ra lỗi hoặc xử lý trường hợp không có người dùng
                throw new UnauthorizedAccessException("Không thể xác định người dùng.");
            }
            var newDeThi = new DeThi
            {
                Tende = request.Tende,
                Thoigiantbatdau = request.Thoigianbatdau.ToUniversalTime(),
                Thoigianketthuc = request.Thoigianketthuc.ToUniversalTime(),
                Thoigianthi = request.Thoigianthi,
                Monthi = request.Monthi,
                Xemdiemthi = request.Xemdiemthi,
                Hienthibailam = request.Hienthibailam,
                Xemdapan = request.Xemdapan,
                Troncauhoi = request.Troncauhoi,
                Loaide = request.Loaide,
                Socaude = request.Socaude,
                Socautb = request.Socautb,
                Socaukho = request.Socaukho,
                Nguoitao = creatorId,
                Thoigiantao = DateTime.UtcNow,
                Trangthai = true
            };

            var selectedLops = await _context.Lops.Where(l => request.Malops.Contains(l.Malop)).ToListAsync();
            newDeThi.Malops = selectedLops;

            // Logic lấy câu hỏi
            if (request.Loaide == 1 && request.Machuongs.Any())
            {
                var cauDe = await GetRandomQuestionsByDifficulty(request.Machuongs, 1, request.Socaude);
                var cauTB = await GetRandomQuestionsByDifficulty(request.Machuongs, 2, request.Socautb);
                var cauKho = await GetRandomQuestionsByDifficulty(request.Machuongs, 3, request.Socaukho);

                foreach (var question in cauDe.Concat(cauTB).Concat(cauKho))
                {
                    newDeThi.ChiTietDeThis.Add(new ChiTietDeThi { Macauhoi = question.Macauhoi, Diemcauhoi = 1 });
                }
            }

            _context.DeThis.Add(newDeThi);
            await _context.SaveChangesAsync();

            return new DeThiViewModel
            {
                Made = newDeThi.Made,
                Tende = newDeThi.Tende,
                Thoigianbatdau = newDeThi.Thoigiantbatdau.Value,
                Thoigianketthuc = newDeThi.Thoigianketthuc.Value,
                // Dùng lại logic của GetAllAsync để tạo chuỗi "GiaoCho"
                GiaoCho = newDeThi.Malops.Any() ? string.Join(", ", newDeThi.Malops.Select(l => l.Tenlop)) : "Chưa giao",
                // Dùng lại logic của GetAllAsync để xác định "Trangthai"
                Trangthai = newDeThi.Trangthai ?? false
            };
        }

        // UPDATE
        public async Task<bool> UpdateAsync(int id, DeThiUpdateRequest request)
        {
            var deThi = await _context.DeThis
                .Include(d => d.Malops)
                .FirstOrDefaultAsync(d => d.Made == id);

            if (deThi == null) return false;

            // Cập nhật các thuộc tính
            deThi.Tende = request.Tende;
            deThi.Thoigiantbatdau = request.Thoigianbatdau.ToUniversalTime();
            // ... các trường khác

            // Cập nhật danh sách lớp được giao
            deThi.Malops.Clear();
            var newLops = await _context.Lops.Where(l => request.Malops.Contains(l.Malop)).ToListAsync();
            foreach (var lop in newLops)
            {
                deThi.Malops.Add(lop);
            }

            // Logic cập nhật câu hỏi phức tạp hơn, có thể cần xóa chi tiết cũ và thêm mới
            // Tạm thời bỏ qua để đơn giản

            _context.DeThis.Update(deThi);
            await _context.SaveChangesAsync();
            return true;
        }

        // DELETE
        public async Task<bool> DeleteAsync(int id)
        {
            var deThi = await _context.DeThis.FindAsync(id);
            if (deThi == null) return false;
            deThi.Trangthai = false;
            _context.Entry(deThi).State = EntityState.Modified;

            return await _context.SaveChangesAsync() > 0;
        }
        public async Task<bool> CapNhatChiTietDeThiAsync(int maDe, CapNhatChiTietDeThiRequest request)
        {
            // Tìm đề thi và các chi tiết hiện có
            var deThi = await _context.DeThis
                .Include(d => d.ChiTietDeThis)
                .FirstOrDefaultAsync(d => d.Made == maDe);

            if (deThi == null)
            {
                return false; // Trả về false để Controller biết là NotFound
            }

            // Xóa tất cả các chi tiết cũ
            _context.ChiTietDeThis.RemoveRange(deThi.ChiTietDeThis);

            // Thêm lại các chi tiết mới từ danh sách ID mà client gửi lên
            if (request.MaCauHois != null && request.MaCauHois.Any())
            {
                var newChiTietList = request.MaCauHois.Select(maCauHoi => new ChiTietDeThi
                {
                    Made = maDe,
                    Macauhoi = maCauHoi,
                    Diemcauhoi = 1 // hoặc một giá trị mặc định nào đó
                }).ToList();

                await _context.ChiTietDeThis.AddRangeAsync(newChiTietList);
            }

            // Lưu tất cả thay đổi
            return await _context.SaveChangesAsync() > 0;
        }
        private async Task<List<CauHoi>> GetRandomQuestionsByDifficulty(List<int> chuongIds, int doKho, int count)
        {
            if (count <= 0) return new List<CauHoi>();
            return await _context.CauHois
                .Where(q => chuongIds.Contains(q.Machuong) && q.Dokho == doKho && q.Trangthai == true)
                .OrderBy(q => Guid.NewGuid())
                .Take(count)
                .ToListAsync();
        }
        public async Task<IEnumerable<ExamForClassDto>> GetExamsForClassAsync(int classId, string studentId)
        {
            var now = DateTime.UtcNow;
            var exams = await _context.DeThis
                .Where(d => d.Trangthai == true && d.Malops.Any(l => l.Malop == classId))
                .OrderByDescending(d => d.Thoigiantbatdau)
                .Select(d => new ExamForClassDto
                {
                    Made = d.Made,
                    Tende = d.Tende,
                    TenMonHoc = _context.MonHocs
                                      .Where(m => m.Mamonhoc == d.Monthi)
                                      .Select(m => m.Tenmonhoc)
                                      .FirstOrDefault() ?? "Không xác định",

                    // --- SỬA LỖI: Lấy số câu thực tế trong đề thi ---
                    TongSoCau = _context.ChiTietDeThis.Count(ct => ct.Made == d.Made),
                    // --- KẾT THÚC SỬA LỖI ---

                    Thoigianthi = d.Thoigianthi ?? 0,
                    Thoigiantbatdau = d.Thoigiantbatdau.Value,
                    Thoigianketthuc = d.Thoigianketthuc.Value,

                    TrangthaiThi = (now < d.Thoigiantbatdau) ? "SapDienRa" :
                                   (now > d.Thoigianketthuc) ? "DaKetThuc" : "DangDienRa",
                    KetQuaId = _context.KetQuas
                                    .Where(kq => kq.Made == d.Made && kq.Manguoidung == studentId)
                                    .Select(kq => (int?)kq.Makq)
                                    .FirstOrDefault()
                })
                .ToListAsync();

            return exams;
        }
        public async Task<IEnumerable<ExamForClassDto>> GetAllExamsForStudentAsync(string studentId)
        {
            var now = DateTime.UtcNow;

            var studentClassIds = await _context.ChiTietLops
                .Where(ctl => ctl.Manguoidung == studentId && ctl.Trangthai == true)
                .Select(ctl => ctl.Malop)
                .ToListAsync();

            if (!studentClassIds.Any())
            {
                return new List<ExamForClassDto>();
            }

            var exams = await _context.DeThis
                .Where(d => d.Trangthai == true && d.Malops.Any(l => studentClassIds.Contains(l.Malop)))
                .OrderByDescending(d => d.Thoigiantbatdau)
                .Select(d => new ExamForClassDto
                {
                    Made = d.Made,
                    Tende = d.Tende,
                    TenMonHoc = _context.MonHocs
                                      .Where(m => m.Mamonhoc == d.Monthi)
                                      .Select(m => m.Tenmonhoc)
                                      .FirstOrDefault() ?? "Không xác định",

                    // --- SỬA LỖI: Lấy số câu thực tế trong đề thi ---
                    TongSoCau = _context.ChiTietDeThis.Count(ct => ct.Made == d.Made),
                    // --- KẾT THÚC SỬA LỖI ---

                    Thoigianthi = d.Thoigianthi ?? 0,
                    Thoigiantbatdau = d.Thoigiantbatdau.Value,
                    Thoigianketthuc = d.Thoigianketthuc.Value,

                    TrangthaiThi = (now < d.Thoigiantbatdau) ? "SapDienRa" :
                                   (now > d.Thoigianketthuc) ? "DaKetThuc" : "DangDienRa",
                    KetQuaId = _context.KetQuas
                                    .Where(kq => kq.Made == d.Made && kq.Manguoidung == studentId)
                                    .Select(kq => (int?)kq.Makq)
                                    .FirstOrDefault()
                })
                .ToListAsync();

            return exams;
        }

        public async Task<IEnumerable<ExamQuestionForStudentDto>> GetQuestionsForStudentAsync(int examId, string studentId)
        {
            // 1. Kiểm tra đề thi có tồn tại
            var exam = await _context.DeThis
                .Include(d => d.Malops)
                .FirstOrDefaultAsync(d => d.Made == examId);
            if (exam == null)
            {
                throw new ArgumentException("Đề thi không tồn tại");
            }

            // 2. Kiểm tra thời gian thi - Cho phép vào thi trong khoảng thời gian hợp lý
            var now = DateTime.Now;
            var startTime = exam.Thoigiantbatdau ?? DateTime.MinValue;
            var endTime = exam.Thoigianketthuc ?? DateTime.MaxValue;

            // Cho phép vào thi trước 5 phút và sau khi kết thúc 5 phút (để xử lý sai lệch thời gian)
            var allowedStartTime = startTime.AddMinutes(-5);
            var allowedEndTime = endTime.AddMinutes(5);

            Console.WriteLine($"🕐 Time check - Now: {now}, Allowed: {allowedStartTime} - {allowedEndTime}");

            if (now < allowedStartTime || now > allowedEndTime)
            {
                throw new ArgumentException($"Không trong thời gian thi. Thời gian hiện tại: {now:dd/MM/yyyy HH:mm}, Thời gian thi: {startTime:dd/MM/yyyy HH:mm} - {endTime:dd/MM/yyyy HH:mm}");
            }

            // 3. Kiểm tra sinh viên có quyền thi không (thuộc lớp được giao đề)
            var studentClassIds = await _context.ChiTietLops
                .Where(cl => cl.Manguoidung == studentId)
                .Select(cl => cl.Malop)
                .ToListAsync();

            // Lấy danh sách lớp được giao đề thi từ database - SỬA LỖI LINQ
            var examClassIds = await _context.DeThis
                .Where(d => d.Made == examId)
                .Include(d => d.Malops)
                .SelectMany(d => d.Malops)
                .Select(l => l.Malop)
                .ToListAsync();

            var hasAccess = studentClassIds.Intersect(examClassIds).Any();

            if (!hasAccess)
            {
                throw new UnauthorizedAccessException("Không có quyền thi đề này");
            }

            // 4. Kiểm tra sinh viên đã thi chưa
            var hasTaken = await _context.KetQuas
                .AnyAsync(kq => kq.Made == examId && kq.Manguoidung == studentId);

            if (hasTaken)
            {
                throw new InvalidOperationException("Đã thi đề này rồi");
            }

            // 5. Lấy câu hỏi và đáp án (không bao gồm đáp án đúng)
            var questions = await _context.ChiTietDeThis
                .Where(ct => ct.Made == examId)
                .Include(ct => ct.MacauhoiNavigation)
                .ThenInclude(ch => ch.CauTraLois)
                .Select(ct => new ExamQuestionForStudentDto
                {
                    Macauhoi = ct.MacauhoiNavigation.Macauhoi,
                    NoiDung = ct.MacauhoiNavigation.Noidung,
                    DoKho = ct.MacauhoiNavigation.Dokho == 1 ? "Dễ" :
                            ct.MacauhoiNavigation.Dokho == 2 ? "Trung bình" : "Khó",
                    HinhAnhUrl = ct.MacauhoiNavigation.Hinhanhurl,
                    LoaiCauHoi = ct.MacauhoiNavigation.Loaicauhoi, // Thêm loại câu hỏi
                    CauTraLois = ct.MacauhoiNavigation.CauTraLois
                        .Select(ctl => new ExamAnswerForStudentDto
                        {
                            Macautraloi = ctl.Macautl,
                            NoiDung = ctl.Noidungtl
                            // Không trả về Dapan
                        })
                        .ToList()
                })
                .ToListAsync();

            // 6. Trộn thứ tự câu hỏi và đáp án nếu cần
            if (exam.Troncauhoi == true)
            {
                var random = new Random();
                questions = questions.OrderBy(x => random.Next()).ToList();

                foreach (var question in questions)
                {
                    question.CauTraLois = question.CauTraLois.OrderBy(x => random.Next()).ToList();
                }
            }

            return questions;
        }
    }
}