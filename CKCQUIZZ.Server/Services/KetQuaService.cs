using CKCQUIZZ.Server.Interfaces;
using CKCQUIZZ.Server.Models;
using CKCQUIZZ.Server.Viewmodels.KetQua;
using Microsoft.EntityFrameworkCore;

namespace CKCQUIZZ.Server.Services
{
    public class KetQuaService : IKetQuaService
    {
        private readonly CkcquizzContext _context;

        public KetQuaService(CkcquizzContext context)
        {
            _context = context;
        }

        public async Task<ExamResultForFlutterDto> SubmitExamAsync(SubmitExamRequestDto request)
        {
            using var transaction = await _context.Database.BeginTransactionAsync();
            try
            {
                // 1. Kiểm tra đề thi có tồn tại và hợp lệ
                var exam = await _context.DeThis
                    .FirstOrDefaultAsync(d => d.Made == request.Made);

                if (exam == null)
                {
                    throw new ArgumentException("Đề thi không tồn tại");
                }

                // 2. Kiểm tra thời gian thi
                var now = DateTime.Now;
                if (now < exam.Thoigiantbatdau || now > exam.Thoigianketthuc)
                {
                    throw new InvalidOperationException("Không trong thời gian thi");
                }

                // 3. Kiểm tra sinh viên đã thi chưa
                var existingResult = await _context.KetQuas
                    .FirstOrDefaultAsync(kq => kq.Made == request.Made && kq.Manguoidung == request.Manguoidung);

                if (existingResult != null)
                {
                    throw new InvalidOperationException("Sinh viên đã thi đề này rồi");
                }

                // 4. Lấy danh sách câu hỏi của đề thi
                var examQuestions = await _context.ChiTietDeThis
                    .Where(ct => ct.Made == request.Made)
                    .Include(ct => ct.MacauhoiNavigation)
                    .ThenInclude(ch => ch.CauTraLois)
                    .ToListAsync();

                if (!examQuestions.Any())
                {
                    throw new ArgumentException("Đề thi không có câu hỏi");
                }

                // 5. Tính điểm và số câu đúng
                int correctAnswers = 0;
                double totalScore = 0;
                var answerDetails = new List<ChiTietKetQua>();
                var studentAnswerDetails = new List<ChiTietTraLoiSinhVien>();

                foreach (var examQuestion in examQuestions)
                {
                    var question = examQuestion.MacauhoiNavigation;
                    var studentAnswer = request.ChiTietTraLoi
                        .FirstOrDefault(a => a.Macauhoi == question.Macauhoi);

                    double questionScore = 0;
                    bool isCorrect = false;

                    // Xử lý theo loại câu hỏi
                    switch (question.Loaicauhoi?.ToLower())
                    {
                        case "single_choice":
                            isCorrect = ProcessSingleChoiceAnswer(question, studentAnswer, out questionScore);
                            break;
                        case "multiple_choice":
                            isCorrect = ProcessMultipleChoiceAnswer(question, studentAnswer, out questionScore);
                            break;
                        case "essay":
                            isCorrect = ProcessEssayAnswer(question, studentAnswer, out questionScore);
                            break;
                        default:
                            // Default to single choice
                            isCorrect = ProcessSingleChoiceAnswer(question, studentAnswer, out questionScore);
                            break;
                    }

                    questionScore = questionScore / examQuestions.Count; // Normalize score
                    if (isCorrect) correctAnswers++;
                    totalScore += questionScore;

                    // Tạo chi tiết kết quả
                    var answerDetail = new ChiTietKetQua
                    {
                        Macauhoi = question.Macauhoi,
                        Diemketqua = questionScore
                    };
                    answerDetails.Add(answerDetail);

                    // Tạo chi tiết trả lời sinh viên
                    CreateStudentAnswerDetails(question, studentAnswer, studentAnswerDetails);
                }

                // 6. Tính thời gian làm bài (phút) - SỬA LỖI: Đảm bảo thời gian dương
                var examDuration = Math.Max(1, (int)(request.Thoigianketthuc - request.Thoigianbatdau).TotalMinutes);

                // 7. Tạo kết quả thi
                var result = new KetQua
                {
                    Made = request.Made,
                    Manguoidung = request.Manguoidung,
                    Diemthi = Math.Round(totalScore, 2),
                    Thoigianvaothi = request.Thoigianbatdau,
                    Thoigiansolambai = examDuration,
                    Socaudung = correctAnswers,
                    Solanchuyentab = 0 // Có thể implement tracking sau
                };

                _context.KetQuas.Add(result);
                await _context.SaveChangesAsync();

                // 8. Lưu chi tiết kết quả trước
                foreach (var detail in answerDetails)
                {
                    detail.Makq = result.Makq;
                }
                _context.ChiTietKetQuas.AddRange(answerDetails);
                await _context.SaveChangesAsync(); // Lưu chi tiết kết quả trước

                // 9. Lưu chi tiết trả lời sinh viên sau
                foreach (var detail in studentAnswerDetails)
                {
                    detail.Makq = result.Makq;
                }
                _context.ChiTietTraLoiSinhViens.AddRange(studentAnswerDetails);
                await _context.SaveChangesAsync(); // Lưu chi tiết trả lời sau
                await transaction.CommitAsync();

                // 10. Trả về kết quả phù hợp với Flutter model
                var completedTime = result.Thoigianvaothi?.AddMinutes(result.Thoigiansolambai ?? 0) ?? DateTime.Now;

                return new ExamResultForFlutterDto
                {
                    Makq = result.Makq,
                    Made = result.Made,
                    Manguoidung = result.Manguoidung,
                    Diem = result.Diemthi ?? 0,
                    Socaudung = result.Socaudung ?? 0,
                    Tongcauhoi = examQuestions.Count,
                    Thoigianbatdau = result.Thoigianvaothi ?? DateTime.Now,
                    Thoigianketthuc = completedTime,
                    Thoigianhoanthanh = completedTime
                };
            }
            catch
            {
                await transaction.RollbackAsync();
                throw;
            }
        }

        public async Task<List<ExamResultDto>> GetResultsByStudentAsync(string studentId)
        {
            var results = await _context.KetQuas
                .Where(kq => kq.Manguoidung == studentId)
                .Include(kq => kq.MadeNavigation)
                .Include(kq => kq.ManguoidungNavigation)
                .Select(kq => new ExamResultDto
                {
                    Makq = kq.Makq,
                    Made = kq.Made,
                    Manguoidung = kq.Manguoidung,
                    TenNguoiDung = kq.ManguoidungNavigation.Hoten,
                    TenDeThi = kq.MadeNavigation.Tende,
                    TenMonHoc = null, // Sẽ lấy từ join khác nếu cần
                    Diemthi = kq.Diemthi,
                    Thoigianvaothi = kq.Thoigianvaothi,
                    Thoigiansolambai = kq.Thoigiansolambai,
                    Socaudung = kq.Socaudung,
                    TongSoCau = _context.ChiTietDeThis.Count(ct => ct.Made == kq.Made),
                    Solanchuyentab = kq.Solanchuyentab,
                    NgayThi = kq.Thoigianvaothi,
                    TrangThai = "DaHoanThanh"
                })
                .OrderByDescending(r => r.NgayThi)
                .ToListAsync();

            return results;
        }

        public async Task<bool> HasStudentTakenExamAsync(int examId, string studentId)
        {
            return await _context.KetQuas
                .AnyAsync(kq => kq.Made == examId && kq.Manguoidung == studentId);
        }

        // Helper methods for processing different question types
        private bool ProcessSingleChoiceAnswer(CauHoi question, StudentAnswerDto? studentAnswer, out double questionScore)
        {
            questionScore = 0;

            var correctAnswer = question.CauTraLois.FirstOrDefault(ct => ct.Dapan == true);
            if (correctAnswer == null) return false;

            bool isCorrect = studentAnswer?.Macautraloi == correctAnswer.Macautl;
            questionScore = isCorrect ? 10.0 : 0;

            return isCorrect;
        }

        private bool ProcessMultipleChoiceAnswer(CauHoi question, StudentAnswerDto? studentAnswer, out double questionScore)
        {
            questionScore = 0;

            var correctAnswers = question.CauTraLois.Where(ct => ct.Dapan == true).ToList();
            if (!correctAnswers.Any()) return false;

            var selectedAnswers = studentAnswer?.DanhSachMacautraloi ?? new List<int>();
            var correctAnswerIds = correctAnswers.Select(ca => ca.Macautl).ToList();

            // Tính điểm theo tỷ lệ đúng
            var correctSelected = selectedAnswers.Intersect(correctAnswerIds).Count();
            var incorrectSelected = selectedAnswers.Except(correctAnswerIds).Count();
            var totalCorrect = correctAnswerIds.Count;

            // Điểm = (số đúng - số sai) / tổng số đúng * 10, tối thiểu 0
            questionScore = Math.Max(0, (double)(correctSelected - incorrectSelected) / totalCorrect * 10);

            // Coi là đúng nếu chọn đúng tất cả và không chọn sai
            bool isCorrect = correctSelected == totalCorrect && incorrectSelected == 0;

            return isCorrect;
        }

        private bool ProcessEssayAnswer(CauHoi question, StudentAnswerDto? studentAnswer, out double questionScore)
        {
            questionScore = 0;

            // Với câu tự luận, tạm thời cho điểm tối đa nếu có trả lời
            // Trong thực tế cần giảng viên chấm điểm
            var essayAnswer = studentAnswer?.CauTraLoiTuLuan?.Trim();

            if (!string.IsNullOrEmpty(essayAnswer))
            {
                questionScore = 10.0; // Tạm thời cho điểm tối đa
                return true;
            }

            return false;
        }

        private void CreateStudentAnswerDetails(CauHoi question, StudentAnswerDto? studentAnswer, List<ChiTietTraLoiSinhVien> studentAnswerDetails)
        {
            if (studentAnswer == null) return;

            switch (question.Loaicauhoi?.ToLower())
            {
                case "single_choice":
                    if (studentAnswer.Macautraloi != null)
                    {
                        // Kiểm tra câu trả lời có tồn tại trong danh sách câu trả lời của câu hỏi
                        var validAnswer = question.CauTraLois.FirstOrDefault(ct => ct.Macautl == studentAnswer.Macautraloi.Value);
                        if (validAnswer != null)
                        {
                            var detail = new ChiTietTraLoiSinhVien
                            {
                                Macauhoi = question.Macauhoi,
                                Macautl = studentAnswer.Macautraloi.Value,
                                Dapansv = studentAnswer.Macautraloi.Value,
                                Thoigiantraloi = studentAnswer.Thoigiantraloi
                            };
                            studentAnswerDetails.Add(detail);
                        }
                    }
                    break;

                case "multiple_choice":
                    if (studentAnswer.DanhSachMacautraloi != null && studentAnswer.DanhSachMacautraloi.Any())
                    {
                        foreach (var answerId in studentAnswer.DanhSachMacautraloi)
                        {
                            // Kiểm tra câu trả lời có tồn tại trong danh sách câu trả lời của câu hỏi
                            var validAnswer = question.CauTraLois.FirstOrDefault(ct => ct.Macautl == answerId);
                            if (validAnswer != null)
                            {
                                var detail = new ChiTietTraLoiSinhVien
                                {
                                    Macauhoi = question.Macauhoi,
                                    Macautl = answerId,
                                    Dapansv = answerId,
                                    Thoigiantraloi = studentAnswer.Thoigiantraloi
                                };
                                studentAnswerDetails.Add(detail);
                            }
                        }
                    }
                    break;

                case "essay":
                    // Với câu tự luận, không lưu vào ChiTietTraLoiSinhVien vì không có câu trả lời cụ thể
                    // Chỉ lưu điểm trong ChiTietKetQua là đủ
                    // Nội dung câu trả lời tự luận có thể được lưu riêng trong bảng khác nếu cần
                    break;
            }
        }

        // Implement các method khác...
        public async Task<ExamResultDetailForFlutterDto> GetResultDetailAsync(int resultId, string studentId)
        {
            // 1. Lấy kết quả thi
            var result = await _context.KetQuas
                .Where(kq => kq.Makq == resultId && kq.Manguoidung == studentId)
                .Include(kq => kq.MadeNavigation)
                .Include(kq => kq.ManguoidungNavigation)
                .FirstOrDefaultAsync();

            if (result == null)
            {
                throw new UnauthorizedAccessException("Không tìm thấy kết quả thi hoặc không có quyền truy cập");
            }

            // 2. Lấy chi tiết trả lời của sinh viên
            var studentAnswers = await _context.ChiTietTraLoiSinhViens
                .Where(ct => ct.Makq == resultId)
                .Include(ct => ct.MacauhoiNavigation)
                .ThenInclude(ch => ch.CauTraLois)
                .Include(ct => ct.MacautlNavigation)
                .ToListAsync();

            // 3. Tạo chi tiết trả lời
            var answerDetails = studentAnswers.Select(sa =>
            {
                var question = sa.MacauhoiNavigation;
                var correctAnswer = question.CauTraLois.FirstOrDefault(ct => ct.Dapan == true);
                var studentAnswer = sa.MacautlNavigation;

                return new StudentAnswerDetailDto
                {
                    Macauhoi = sa.Macauhoi,
                    NoiDungCauHoi = question.Noidung ?? "",
                    MacautraloiChon = sa.Macautl,
                    NoiDungTraLoiChon = studentAnswer?.Noidungtl,
                    MacautraloiDung = correctAnswer?.Macautl ?? 0,
                    NoiDungTraLoiDung = correctAnswer?.Noidungtl ?? "",
                    LaDung = sa.Macautl == correctAnswer?.Macautl,
                    DiemKetQua = sa.Macautl == correctAnswer?.Macautl ? (10.0 / studentAnswers.Count) : 0,
                    Thoigiantraloi = sa.Thoigiantraloi
                };
            }).ToList();

            // 4. Tạo DTO kết quả
            var resultDto = new ExamResultDto
            {
                Makq = result.Makq,
                Made = result.Made,
                Manguoidung = result.Manguoidung,
                TenNguoiDung = result.ManguoidungNavigation.Hoten,
                TenDeThi = result.MadeNavigation.Tende,
                TenMonHoc = null, // Có thể lấy từ join khác nếu cần
                Diemthi = result.Diemthi,
                Thoigianvaothi = result.Thoigianvaothi,
                Thoigiansolambai = result.Thoigiansolambai,
                Socaudung = result.Socaudung,
                TongSoCau = studentAnswers.Count,
                Solanchuyentab = result.Solanchuyentab,
                NgayThi = result.Thoigianvaothi,
                TrangThai = "DaHoanThanh"
            };

            return new ExamResultDetailForFlutterDto
            {
                Makq = result.Makq,
                Made = result.Made,
                Tende = result.MadeNavigation.Tende ?? "",
                Manguoidung = result.Manguoidung,
                Hoten = result.ManguoidungNavigation.Hoten ?? "",
                Diem = result.Diemthi ?? 0,
                Socaudung = result.Socaudung ?? 0,
                Tongcauhoi = studentAnswers.Count,
                Thoigianbatdau = result.Thoigianvaothi ?? DateTime.Now,
                Thoigianketthuc = result.Thoigianvaothi?.AddMinutes(result.Thoigiansolambai ?? 0) ?? DateTime.Now,
                Thoigianhoanthanh = result.Thoigianvaothi?.AddMinutes(result.Thoigiansolambai ?? 0) ?? DateTime.Now,
                ChiTietTraLoi = answerDetails
            };
        }

        public async Task<List<ExamResultDto>> GetResultsByExamAsync(int examId, string teacherId)
        {
            // Implementation sẽ được thêm sau
            throw new NotImplementedException();
        }

        public async Task<ExamStatisticsDto> GetExamStatisticsAsync(int examId, string teacherId)
        {
            // Implementation sẽ được thêm sau
            throw new NotImplementedException();
        }
    }
}
