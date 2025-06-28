using CKCQUIZZ.Server.Data;
using CKCQUIZZ.Server.Interfaces;
using CKCQUIZZ.Server.Models;
using CKCQUIZZ.Server.Viewmodels.DeThi;
using CKCQUIZZ.Server.Viewmodels.Student;
using Microsoft.Data.SqlClient;
using Microsoft.EntityFrameworkCore;
using System.Security.Claims;

namespace CKCQUIZZ.Server.Services
{
    public class DeThiService(CkcquizzContext _context, IHttpContextAccessor _httpContextAccessor) : IDeThiService
    {
        private static readonly Random random = new Random();

        public async Task<List<DeThiViewModel>> GetAllAsync()
        {
            var deThis = await _context.DeThis
                .Include(d => d.Malops) // Nạp danh sách các lớp được gán
                .OrderByDescending(d => d.Thoigiantao)
                .ToListAsync();

            var viewModels = deThis.Select(d => new DeThiViewModel
            {
                Made = d.Made,
                Tende = d.Tende,
                Thoigianbatdau = d.Thoigiantbatdau ?? DateTime.MinValue, // Giả định không null
                Thoigianketthuc = d.Thoigianketthuc ?? DateTime.MinValue,
                Monthi = d.Monthi ?? 0,
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
                Thoigiantbatdau = request.Thoigianbatdau,
                Thoigianketthuc = request.Thoigianketthuc,
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
            deThi.Tende = request.Tende;
            deThi.Thoigiantbatdau = request.Thoigianbatdau;
            deThi.Thoigianketthuc = request.Thoigianketthuc;
            //deThi.Malops.Clear();
            //var newLops = await _context.Lops.Where(l => request.Malops.Contains(l.Malop)).ToListAsync();
            //foreach (var lop in newLops)
            //{
            //    deThi.Malops.Add(lop);
            //}
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
                                    .Where(kq => kq.Made == d.Made && kq.Manguoidung == studentId && kq.Thoigianlambai != null) // Only show KetQuaId if exam is submitted
                                    .Select(kq => (int?)kq.Makq)
                                    .FirstOrDefault()
                })
                .ToListAsync(); // Execute the query here

            // After fetching, iterate and log
            foreach (var exam in exams)
            {
                Console.WriteLine($"[DEBUG] Exam: {exam.Tende}, Start: {exam.Thoigiantbatdau}, End: {exam.Thoigianketthuc}, Status: {exam.TrangthaiThi}");
            }

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

                    // Convert database times to UTC before comparison
                    TrangthaiThi = (now < DateTime.SpecifyKind(d.Thoigiantbatdau.Value, DateTimeKind.Local).ToUniversalTime()) ? "SapDienRa" :
                                (now > DateTime.SpecifyKind(d.Thoigianketthuc.Value, DateTimeKind.Local).ToUniversalTime()) ? "DaKetThuc" : "DangDienRa",
                    KetQuaId = _context.KetQuas
                                    .Where(kq => kq.Made == d.Made && kq.Manguoidung == studentId && kq.Thoigianlambai != null) // Only show KetQuaId if exam is submitted
                                    .Select(kq => (int?)kq.Makq)
                                    .FirstOrDefault()
                })
                .ToListAsync();

            return exams;
        }
        public async Task<StudentExamDetailDto> GetExamForStudent(int deThiId, string studentId)
        {
            var deThi = await _context.DeThis
                .Include(d => d.ChiTietDeThis)
                    .ThenInclude(ct => ct.MacauhoiNavigation)
                        .ThenInclude(ch => ch.CauTraLois)
                .FirstOrDefaultAsync(d => d.Made == deThiId && d.Trangthai == true);

            if (deThi == null)
            {
                return null;
            }

            var examDto = new StudentExamDetailDto
            {
                Made = deThi.Made,
                Tende = deThi.Tende,
                Thoigianthi = deThi.Thoigianthi ?? 0,
            };

            var questions = deThi.ChiTietDeThis.Select(ct => ct.MacauhoiNavigation).ToList();

            if (deThi.Troncauhoi == true)
            {
                // Sử dụng seed cố định dựa trên Made và studentId để đảm bảo thứ tự nhất quán cho mỗi sinh viên
                var seed = deThi.Made.GetHashCode() + studentId.GetHashCode();
                var seededRandom = new Random(seed);
                questions = questions.OrderBy(q => seededRandom.Next()).ToList();
            }

            foreach (var question in questions)
            {
                var questionDto = new StudentQuestionDto
                {
                    Macauhoi = question.Macauhoi,
                    Noidung = question.Noidung,
                    Loaicauhoi = question.Loaicauhoi,
                    Hinhanhurl = question.Hinhanhurl,
                };


                var answers = question.CauTraLois.ToList();
                if (deThi.Troncauhoi == true)
                {
                    // Sử dụng seed cố định dựa trên Made, studentId và Macauhoi để đảm bảo thứ tự nhất quán
                    var seed = deThi.Made.GetHashCode() + studentId.GetHashCode() + question.Macauhoi;
                    var seededRandom = new Random(seed);
                    answers = answers.OrderBy(a => seededRandom.Next()).ToList();
                }

                foreach (var answer in answers)
                {
                    questionDto.Answers.Add(new StudentAnswerDto
                    {
                        Macautl = answer.Macautl,
                        Noidungtl = answer.Noidungtl,
                    });
                }
                examDto.Questions.Add(questionDto);
            }

            return examDto;
        }
        public async Task<StartExamResponseDto> StartExam(StartExamRequestDto request, string studentId)
        {
            Console.WriteLine($"[DEBUG] StartExam called with ExamId: {request.ExamId}, StudentId: {studentId}");
            
            var existingResult = await _context.KetQuas
                  .FirstOrDefaultAsync(kq => kq.Made == request.ExamId && kq.Manguoidung == studentId);

            if (existingResult != null)
            {
                Console.WriteLine($"[DEBUG] Found existing result: KetQuaId = {existingResult.Makq}");
                return new StartExamResponseDto
                {
                    KetQuaId = existingResult.Makq,
                    ExamId = existingResult.Made,
                    Thoigianbatdau = existingResult.Thoigianvaothi ?? DateTime.MinValue
                };
            }

            // 2. LẤY THÔNG TIN ĐỀ THI (GIỮ NGUYÊN)
            var deThi = await _context.DeThis
                .Include(d => d.ChiTietDeThis)
                .AsNoTracking()
                .FirstOrDefaultAsync(d => d.Made == request.ExamId && d.Trangthai == true);

            if (deThi == null)
            {
                Console.WriteLine($"[DEBUG] DeThi not found or not active: ExamId = {request.ExamId}");
                throw new KeyNotFoundException("Không tìm thấy đề thi hoặc đề thi không hoạt động.");
            }

            Console.WriteLine($"[DEBUG] Found DeThi: {deThi.Tende}, ChiTietDeThis count: {deThi.ChiTietDeThis.Count}");

            // 3. TẠO BẢN GHI KETQUA (GIỮ NGUYÊN)
            var newKetQua = new KetQua
            {
                Made = request.ExamId,
                Manguoidung = studentId,
                Thoigianvaothi = DateTime.UtcNow,
                Diemthi = 0,
                Socaudung = 0,
                Thoigianlambai = null
            };
            _context.KetQuas.Add(newKetQua);
            await _context.SaveChangesAsync(); // Lưu để có Makq

            Console.WriteLine($"[DEBUG] Created new KetQua: Makq = {newKetQua.Makq}");

            // 4. KHỞI TẠO CÂU TRẢ LỜI
            // ---- PHẦN THAY ĐỔI BẮT ĐẦU TỪ ĐÂY ----

            // 4.1. Tạo ChiTietKetQua trước
            var chiTietKetQuaList = deThi.ChiTietDeThis.Select(ct => new ChiTietKetQua
            {
                Makq = newKetQua.Makq,
                Macauhoi = ct.Macauhoi,
                Diemketqua = 0
            }).ToList();

            if (chiTietKetQuaList.Any())
            {
                await _context.ChiTietKetQuas.AddRangeAsync(chiTietKetQuaList);
                Console.WriteLine($"[DEBUG] Added {chiTietKetQuaList.Count} ChiTietKetQua records");
                
                // Lưu ChiTietKetQua trước khi gọi stored procedure
                await _context.SaveChangesAsync();
                Console.WriteLine($"[DEBUG] Saved ChiTietKetQua to database");
            }

            // 4.2. Dùng Stored Procedure để khởi tạo ChiTietTraLoiSinhVien
            foreach (var chiTietDeThi in deThi.ChiTietDeThis)
            {
                try
                {
                    var maKqParam = new SqlParameter("@MaKQ", newKetQua.Makq);
                    var maCauHoiParam = new SqlParameter("@MaCauHoi", chiTietDeThi.Macauhoi);

                    Console.WriteLine($"[DEBUG] Calling SP for Macauhoi: {chiTietDeThi.Macauhoi}");

                    // Gọi Stored Procedure
                    await _context.Database.ExecuteSqlRawAsync(
                        "EXEC dbo.KhoiTaoCauTraLoiSinhVien @MaKQ, @MaCauHoi",
                        maKqParam,
                        maCauHoiParam
                    );
                }
                catch (Exception ex)
                {
                    Console.WriteLine($"[ERROR] Failed to execute SP for Macauhoi {chiTietDeThi.Macauhoi}: {ex.Message}");
                    throw;
                }
            }

            Console.WriteLine($"[DEBUG] StartExam completed successfully. Returning KetQuaId: {newKetQua.Makq}");

            return new StartExamResponseDto
            {
                KetQuaId = newKetQua.Makq,
                ExamId = newKetQua.Made,
                Thoigianbatdau = newKetQua.Thoigianvaothi ?? DateTime.MinValue
            };
        }

        public async Task<ExamResultDto> SubmitExam(SubmitExamRequestDto submission, string studentId)
        {
            // 1. Lấy kết quả thi và thông tin đề thi (giữ nguyên)
            var existingResult = await _context.KetQuas
                .FirstOrDefaultAsync(kq => kq.Makq == submission.KetQuaId && kq.Manguoidung == studentId);

            if (existingResult == null)
            {
                throw new KeyNotFoundException("Không tìm thấy kết quả bài thi để nộp.");
            }

            var deThi = await _context.DeThis
                .Include(d => d.ChiTietDeThis)
                    .ThenInclude(ct => ct.MacauhoiNavigation)
                        .ThenInclude(ch => ch.CauTraLois)
                .AsNoTracking()
                .FirstOrDefaultAsync(d => d.Made == existingResult.Made);

            if (deThi == null)
            {
                throw new KeyNotFoundException("Không tìm thấy đề thi liên quan.");
            }

            // 2. Lấy đáp án đúng và câu trả lời của sinh viên (giữ nguyên)
            // Lấy cả object CauTraLoi để có thể truy cập noidungtl cho câu essay
            var correctAnswersLookup = deThi.ChiTietDeThis
                .SelectMany(ct => ct.MacauhoiNavigation.CauTraLois)
                .Where(ans => ans.Dapan == true)
                .ToLookup(ans => ans.Macauhoi, ans => ans);

            var studentAnswers = await _context.ChiTietTraLoiSinhViens
                .Where(ct => ct.Makq == submission.KetQuaId)
                .ToListAsync();

            // 3. Vòng lặp chấm điểm
            int soCauDung = 0;
            foreach (var questionDetail in deThi.ChiTietDeThis)
            {
                var question = questionDetail.MacauhoiNavigation;
                int macauhoi = question.Macauhoi;

                // Xử lý single_choice (đã sửa)
                if (question.Loaicauhoi == "single_choice")
                {
                    var correctAnswerId = correctAnswersLookup[macauhoi].FirstOrDefault()?.Macautl;
                    var studentAnswerId = studentAnswers.FirstOrDefault(a => a.Macauhoi == macauhoi && a.Dapansv == 1)?.Macautl;
                    if (correctAnswerId.HasValue && studentAnswerId.HasValue && correctAnswerId == studentAnswerId)
                    {
                        soCauDung++;
                    }
                }
                // Xử lý multiple_choice (đã sửa)
                else if (question.Loaicauhoi == "multiple_choice")
                {
                    var correctSet = correctAnswersLookup[macauhoi].Select(a => a.Macautl).ToHashSet();
                    var studentSet = studentAnswers.Where(a => a.Macauhoi == macauhoi && a.Dapansv == 1).Select(a => a.Macautl).ToHashSet();
                    if (correctSet.Any() && correctSet.SetEquals(studentSet))
                    {
                        soCauDung++;
                    }
                }
                // *** LOGIC MỚI ĐỂ CHẤM CÂU ESSAY (TRẢ LỜI NGẮN) ***
                else if (question.Loaicauhoi == "essay")
                {
                    // Lấy nội dung đáp án đúng từ DB
                    var correctAnswerText = correctAnswersLookup[macauhoi].FirstOrDefault()?.Noidungtl;

                    // Lấy câu trả lời mà sinh viên đã nhập
                    var studentAnswerText = studentAnswers.FirstOrDefault(a => a.Macauhoi == macauhoi)?.Dapantuluansv;

                    // Chỉ so sánh nếu cả hai đều có giá trị
                    if (!string.IsNullOrWhiteSpace(correctAnswerText) && !string.IsNullOrWhiteSpace(studentAnswerText))
                    {
                        // So sánh "thông minh": bỏ qua khoảng trắng thừa và không phân biệt hoa/thường
                        if (correctAnswerText.Trim().Equals(studentAnswerText.Trim(), StringComparison.OrdinalIgnoreCase))
                        {
                            soCauDung++;
                        }
                    }
                }
            }

            // 4. Cập nhật điểm và lưu kết quả (giữ nguyên)
            int tongSoCau = deThi.ChiTietDeThis.Count;
            double diemThi = (tongSoCau > 0) ? ((double)soCauDung / tongSoCau) * 10.0 : 0.0;

            existingResult.Diemthi = diemThi;
            existingResult.Socaudung = soCauDung;
            existingResult.Thoigianlambai = submission.ThoiGianLamBai;

            _context.KetQuas.Update(existingResult);
            await _context.SaveChangesAsync();

            return new ExamResultDto
            {
                KetQuaId = existingResult.Makq,
                DiemThi = existingResult.Diemthi ?? 0,
                SoCauDung = soCauDung,
                TongSoCau = tongSoCau
            };
        }
        public async Task<object> GetStudentExamResult(int ketQuaId, string studentId)
        {
            // Lấy kết quả và đề thi
            var ketQua = await _context.KetQuas
                .Include(kq => kq.MadeNavigation)
                .FirstOrDefaultAsync(kq => kq.Makq == ketQuaId && kq.Manguoidung == studentId);

            if (ketQua == null) return null;

            var deThi = ketQua.MadeNavigation;

            // Lấy điểm nếu cho phép
            double? diem = deThi.Xemdiemthi == true ? ketQua.Diemthi : null;

            // Lấy chi tiết bài làm nếu cho phép
            List<ChiTietTraLoiSinhVien> chiTietBaiLam = null;
            if (deThi.Hienthibailam == true)
            {
                chiTietBaiLam = await _context.ChiTietTraLoiSinhViens
                    .Where(ct => ct.Makq == ketQuaId)
                    .ToListAsync();
            }

            // Lấy đáp án đúng nếu cho phép
            Dictionary<int, int> dapAnDung = null;
            if (deThi.Xemdapan == true)
            {
                dapAnDung = await _context.ChiTietDeThis
                    .Where(ct => ct.Made == deThi.Made)
                    .Select(ct => new
                    {
                        ct.Macauhoi,
                        MacautlDung = ct.MacauhoiNavigation.CauTraLois.FirstOrDefault(a => a.Dapan == true).Macautl
                    })
                    .ToDictionaryAsync(x => x.Macauhoi, x => x.MacautlDung);
            }

            // Nếu đề thi trộn câu hỏi, có thể random lại thứ tự khi trả về (nếu cần)
            // Thường chỉ trộn khi phát đề, không cần trộn khi xem lại

            return new
            {
                Diem = diem,
                BaiLam = chiTietBaiLam, // null nếu không cho xem
                DapAn = dapAnDung       // null nếu không cho xem
            };
        }
        public async Task<bool> UpdateStudentAnswer(UpdateAnswerRequestDto request, string studentId)
        {
            // 1. Xác thực quyền truy cập
            var ketQua = await _context.KetQuas
                     .AsNoTracking()
                     .FirstOrDefaultAsync(kq => kq.Makq == request.KetQuaId && kq.Manguoidung == studentId);

            if (ketQua == null)
            {
                throw new KeyNotFoundException("Không tìm thấy kết quả bài thi hoặc sinh viên không có quyền truy cập.");
            }

            // 2. Lấy loại câu hỏi để xử lý logic phù hợp
            var questionType = await _context.CauHois
                .Where(ch => ch.Macauhoi == request.Macauhoi)
                .Select(ch => ch.Loaicauhoi)
                .FirstOrDefaultAsync();

            if (questionType == null) throw new KeyNotFoundException("Không tìm thấy câu hỏi.");

            // 3. Phân luồng xử lý dựa trên loại câu hỏi
            if (questionType == "single_choice")
            {
                // Tìm tất cả các lựa chọn đã lưu cho câu hỏi này
                var allOptionsForQuestion = await _context.ChiTietTraLoiSinhViens
                    .Where(ct => ct.Makq == request.KetQuaId && ct.Macauhoi == request.Macauhoi)
                    .ToListAsync();

                // Bỏ chọn tất cả các lựa chọn cũ
                foreach (var option in allOptionsForQuestion)
                {
                    option.Dapansv = 0;
                }

                // Chọn cái mới (nếu có)
                if (request.Macautl != 0)
                {
                    var selectedOption = allOptionsForQuestion.FirstOrDefault(o => o.Macautl == request.Macautl);
                    if (selectedOption != null)
                    {
                        selectedOption.Dapansv = 1;
                    }
                }
            }
            else if (questionType == "multiple_choice")
            {
                // *** LOGIC MỚI CHO CHỌN NHIỀU ĐÁP ÁN ***
                // Với multiple choice, frontend sẽ gửi dapansv cụ thể (0 hoặc 1)
                // cho từng đáp án được chọn/bỏ chọn

                // Tìm chính xác câu trả lời mà sinh viên vừa click
                var studentAnswer = await _context.ChiTietTraLoiSinhViens
                    .FirstOrDefaultAsync(ct => ct.Makq == request.KetQuaId &&
                                                ct.Macauhoi == request.Macauhoi &&
                                                ct.Macautl == request.Macautl);

                if (studentAnswer != null)
                {
                    // Sử dụng dapansv từ request nếu có, ngược lại đảo ngược trạng thái hiện tại
                    if (request.Dapansv.HasValue)
                    {
                        studentAnswer.Dapansv = request.Dapansv.Value;
                    }
                    else
                    {
                        // Fallback: đảo ngược trạng thái nếu không có dapansv trong request
                        studentAnswer.Dapansv = (studentAnswer.Dapansv == 1) ? 0 : 1;
                    }
                    Console.WriteLine($"[DEBUG] Multiple choice updated: Macauhoi={request.Macauhoi}, Macautl={request.Macautl}, Dapansv={studentAnswer.Dapansv}");
                }
                else
                {
                    // Ghi log cảnh báo nếu không tìm thấy, có thể là lỗi từ frontend
                    Console.WriteLine($"[WARNING] Không tìm thấy ChiTietTraLoiSinhVien (multiple_choice) cho Makq: {request.KetQuaId}, Macauhoi: {request.Macauhoi}, Macautl: {request.Macautl}");
                }
            }
            else if (questionType == "essay")
            {
                // Logic cho câu tự luận không đổi
                // Tìm bản ghi tự luận (nơi Macautl = Macauhoi theo thiết kế của SP)
                var essayAnswer = await _context.ChiTietTraLoiSinhViens
                    .FirstOrDefaultAsync(ct => ct.Makq == request.KetQuaId && ct.Macauhoi == request.Macauhoi && ct.Macautl == request.Macauhoi);

                if (essayAnswer != null)
                {
                    essayAnswer.Dapantuluansv = request.Dapantuluansv;
                }
                else
                {
                    Console.WriteLine($"[WARNING] Không tìm thấy ChiTietTraLoiSinhVien cho câu tự luận. Makq: {request.KetQuaId}, Macauhoi: {request.Macauhoi}");
                }
            }

            await _context.SaveChangesAsync();
            return true;
        }
    }
}
