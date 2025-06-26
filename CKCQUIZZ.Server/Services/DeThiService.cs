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

                        // --- THAY ĐỔI CHÍNH Ở ĐÂY ---
                        // Tính tổng số câu từ các mức độ
                        TongSoCau = (d.Socaude ?? 0) + (d.Socautb ?? 0) + (d.Socaukho ?? 0),
                        // --- KẾT THÚC THAY ĐỔI ---

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

                        // --- THAY ĐỔI CHÍNH Ở ĐÂY ---
                        // Tính tổng số câu từ các mức độ
                        TongSoCau = (d.Socaude ?? 0) + (d.Socautb ?? 0) + (d.Socaukho ?? 0),
                        // --- KẾT THÚC THAY ĐỔI ---

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
            public async Task<StudentExamDetailDto> GetExamForStudent(int deThiId)
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

                    questions = questions.OrderBy(q => random.Next()).ToList();
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

                        answers = answers.OrderBy(a => random.Next()).ToList();
                    }

                    foreach (var answer in answers)
                    {
                        questionDto.Answers.Add(new StudentAnswerDto
                        {
                            Macautl = answer.Macautl,
                            Noidungtl = answer.Noidungtl,
                            Hinhanh = answer.Hinhanh
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
                };

                _context.KetQuas.Add(newKetQua);
                await _context.SaveChangesAsync();

                return new ExamResultDto
                {
                    KetQuaId = newKetQua.Makq,
                    DiemThi = newKetQua.Diemthi ?? 0,
                    SoCauDung = soCauDung,
                    TongSoCau = tongSoCau
                };
            }
        }
    }
