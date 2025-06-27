using CKCQUIZZ.Server.Data;
using CKCQUIZZ.Server.Interfaces;
using CKCQUIZZ.Server.Models;
using CKCQUIZZ.Server.Viewmodels.DeThi;
using CKCQUIZZ.Server.Viewmodels.Student;
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
                                    .Where(kq => kq.Made == d.Made && kq.Manguoidung == studentId)
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
                                    .Where(kq => kq.Made == d.Made && kq.Manguoidung == studentId)
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
        public async Task<ExamResultDto> SubmitExam(SubmitExamRequestDto submission, string studentId)
        {
            var existingResult = await _context.KetQuas
                .FirstOrDefaultAsync(kq => kq.Made == submission.ExamId && kq.Manguoidung == studentId);

            if (existingResult != null)
            {
                throw new InvalidOperationException("Bạn đã nộp bài cho kỳ thi này rồi.");
            }

            var deThi = await _context.DeThis
                .Include(d => d.ChiTietDeThis)
                    .ThenInclude(ct => ct.MacauhoiNavigation)
                        .ThenInclude(ch => ch.CauTraLois)
                .AsNoTracking()
                .FirstOrDefaultAsync(d => d.Made == submission.ExamId);

            if (deThi == null)
            {
                throw new KeyNotFoundException("Không tìm thấy đề thi.");
            }

            var correctAnswers = deThi.ChiTietDeThis
                .SelectMany(ct => ct.MacauhoiNavigation.CauTraLois)
                .Where(ans => ans.Dapan == true)
                .ToDictionary(ans => ans.Macauhoi, ans => ans.Macautl);

            int soCauDung = 0;
            var userAnswersDict = submission.Answers.ToDictionary(a => a.QuestionId, a => a.SelectedAnswerId);

            foreach (var question in deThi.ChiTietDeThis.Select(ct => ct.MacauhoiNavigation))
            {
                // Kiểm tra xem câu hỏi này có đáp án đúng không và SV có trả lời không
                if (correctAnswers.TryGetValue(question.Macauhoi, out int correctAnserId) &&
                    userAnswersDict.TryGetValue(question.Macauhoi, out int userAnswerId))
                {
                    if (correctAnserId == userAnswerId)
                    {
                        soCauDung++;
                    }
                }
            }

            int tongSoCau = deThi.ChiTietDeThis.Count;
            double diemThi = (tongSoCau > 0) ? ((double)soCauDung / tongSoCau) * 10.0 : 0.0;

            var newKetQua = new KetQua
            {
                Made = submission.ExamId,
                Manguoidung = studentId,
                Diemthi = diemThi,
                Socaudung = soCauDung,
                Thoigianvaothi = DateTime.UtcNow,
                Thoigiansolambai = submission.ThoiGianSoLamBai ?? null,
            };

            Console.WriteLine($"[DEBUG] Thoigiansolambai before save: {newKetQua.Thoigiansolambai}");

            _context.KetQuas.Add(newKetQua);
            await _context.SaveChangesAsync();

            // Lưu chi tiết từng đáp án sinh viên đã chọn
            var chiTietList = new List<ChiTietTraLoiSinhVien>();
            var chiTietKetQuaList = new List<ChiTietKetQua>();
            foreach (var answer in submission.Answers)
            {
                var chiTiet = new ChiTietTraLoiSinhVien
                {
                    Makq = newKetQua.Makq, // id của kết quả vừa tạo
                    Macauhoi = answer.QuestionId,
                    Macautl = answer.SelectedAnswerId,
                    Dapansv = answer.SelectedAnswerId // hoặc có thể là giá trị khác nếu bạn muốn
                };
                chiTietList.Add(chiTiet);
            }
            // Lưu điểm từng câu hỏi vào ChiTietKetQua
            foreach (var question in deThi.ChiTietDeThis.Select(ct => ct.MacauhoiNavigation))
            {
                double diem = 0;
                if (correctAnswers.TryGetValue(question.Macauhoi, out int correctAnserId) &&
                    userAnswersDict.TryGetValue(question.Macauhoi, out int userAnswerId) &&
                    correctAnserId == userAnswerId)
                {
                    diem = 1; // hoặc điểm khác nếu có trọng số
                }
                var chiTietKQ = new ChiTietKetQua
                {
                    Makq = newKetQua.Makq,
                    Macauhoi = question.Macauhoi,
                    Diemketqua = diem
                };
                chiTietKetQuaList.Add(chiTietKQ);
            }
            if (chiTietList.Count > 0)
            {
                await _context.ChiTietTraLoiSinhViens.AddRangeAsync(chiTietList);
                if (chiTietKetQuaList.Count > 0)
                {
                    await _context.ChiTietKetQuas.AddRangeAsync(chiTietKetQuaList);
                }
                await _context.SaveChangesAsync();
            }

            return new ExamResultDto
            {
                KetQuaId = newKetQua.Makq,
                DiemThi = newKetQua.Diemthi ?? 0,
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
    }
}
