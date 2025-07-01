using CKCQUIZZ.Server.Data;
using CKCQUIZZ.Server.Models;
using Microsoft.EntityFrameworkCore;

namespace CKCQUIZZ.Server.Services
{
    /// <summary>
    /// Service chuyên dụng để chấm điểm bài thi
    /// Đảm bảo logic chấm điểm nhất quán trong toàn bộ hệ thống
    /// </summary>
    public class ExamScoringService
    {
        private readonly CkcquizzContext _context;

        public ExamScoringService(CkcquizzContext context)
        {
            _context = context;
        }

        /// <summary>
        /// Chấm điểm cho một bài thi cụ thể
        /// </summary>
        public async Task<ExamScoringResult> ScoreExam(int ketQuaId)
        {
            var ketQua = await _context.KetQuas
                .FirstOrDefaultAsync(kq => kq.Makq == ketQuaId);

            if (ketQua == null)
            {
                throw new KeyNotFoundException($"Không tìm thấy kết quả thi với ID: {ketQuaId}");
            }

            var deThi = await _context.DeThis
                .Include(d => d.ChiTietDeThis)
                    .ThenInclude(ct => ct.MacauhoiNavigation)
                        .ThenInclude(ch => ch.CauTraLois)
                .AsNoTracking()
                .FirstOrDefaultAsync(d => d.Made == ketQua.Made);

            if (deThi == null)
            {
                throw new KeyNotFoundException($"Không tìm thấy đề thi với ID: {ketQua.Made}");
            }

            // Lấy đáp án đúng
            var correctAnswersLookup = deThi.ChiTietDeThis
                .SelectMany(ct => ct.MacauhoiNavigation.CauTraLois)
                .Where(ans => ans.Dapan == true)
                .ToLookup(ans => ans.Macauhoi, ans => ans);

            // Lấy đáp án của sinh viên
            var studentAnswers = await _context.ChiTietTraLoiSinhViens
                .Where(ct => ct.Makq == ketQuaId)
                .ToListAsync();

            var result = new ExamScoringResult
            {
                KetQuaId = ketQuaId,
                ExamId = ketQua.Made,
                StudentId = ketQua.Manguoidung,
                TotalQuestions = deThi.ChiTietDeThis.Count
            };

            // Chấm từng câu hỏi
            foreach (var questionDetail in deThi.ChiTietDeThis)
            {
                var question = questionDetail.MacauhoiNavigation;
                var questionResult = ScoreQuestion(question, correctAnswersLookup[question.Macauhoi], studentAnswers);
                result.QuestionResults.Add(questionResult);
                
                if (questionResult.IsCorrect)
                {
                    result.CorrectAnswers++;
                }
            }

            // Tính điểm
            result.Score = result.TotalQuestions > 0 
                ? ((double)result.CorrectAnswers / result.TotalQuestions) * 10.0 
                : 0.0;

            return result;
        }

        /// <summary>
        /// Chấm điểm cho một câu hỏi cụ thể
        /// </summary>
        private QuestionScoringResult ScoreQuestion(
            CauHoi question, 
            IEnumerable<CauTraLoi> correctAnswers, 
            List<ChiTietTraLoiSinhVien> allStudentAnswers)
        {
            var questionStudentAnswers = allStudentAnswers
                .Where(sa => sa.Macauhoi == question.Macauhoi)
                .ToList();

            var result = new QuestionScoringResult
            {
                QuestionId = question.Macauhoi,
                QuestionType = question.Loaicauhoi ?? "single_choice",
                QuestionContent = question.Noidung ?? ""
            };

            switch (question.Loaicauhoi?.ToLower())
            {
                case "single_choice":
                    result.IsCorrect = ScoreSingleChoice(correctAnswers, questionStudentAnswers);
                    break;
                case "multiple_choice":
                    result.IsCorrect = ScoreMultipleChoice(correctAnswers, questionStudentAnswers);
                    break;
                case "essay":
                    result.IsCorrect = ScoreEssay(correctAnswers, questionStudentAnswers);
                    break;
                default:
                    result.IsCorrect = ScoreSingleChoice(correctAnswers, questionStudentAnswers);
                    break;
            }

            return result;
        }

        /// <summary>
        /// Chấm câu hỏi single choice
        /// </summary>
        private bool ScoreSingleChoice(IEnumerable<CauTraLoi> correctAnswers, List<ChiTietTraLoiSinhVien> studentAnswers)
        {
            var correctAnswerId = correctAnswers.FirstOrDefault()?.Macautl;
            var selectedAnswers = studentAnswers.Where(sa => sa.Dapansv == 1).ToList();

            // Kiểm tra có chọn đúng 1 đáp án không
            if (selectedAnswers.Count != 1)
            {
                return false; // Không chọn gì hoặc chọn nhiều đáp án
            }

            var selectedAnswerId = selectedAnswers.First().Macautl;
            return correctAnswerId.HasValue && selectedAnswerId == correctAnswerId.Value;
        }

        /// <summary>
        /// Chấm câu hỏi multiple choice
        /// </summary>
        private bool ScoreMultipleChoice(IEnumerable<CauTraLoi> correctAnswers, List<ChiTietTraLoiSinhVien> studentAnswers)
        {
            var correctAnswerIds = correctAnswers.Select(ca => ca.Macautl).ToHashSet();
            var selectedAnswerIds = studentAnswers
                .Where(sa => sa.Dapansv == 1)
                .Select(sa => sa.Macautl)
                .ToHashSet();

            // Phải chọn đúng tất cả đáp án đúng và không chọn đáp án sai
            return correctAnswerIds.Count > 0 && correctAnswerIds.SetEquals(selectedAnswerIds);
        }

        /// <summary>
        /// Chấm câu hỏi essay
        /// </summary>
        private bool ScoreEssay(IEnumerable<CauTraLoi> correctAnswers, List<ChiTietTraLoiSinhVien> studentAnswers)
        {
            var correctAnswerText = correctAnswers.FirstOrDefault()?.Noidungtl;
            var studentAnswerText = studentAnswers.FirstOrDefault()?.Dapantuluansv;

            if (string.IsNullOrWhiteSpace(correctAnswerText) || string.IsNullOrWhiteSpace(studentAnswerText))
            {
                return false;
            }

            // So sánh không phân biệt hoa thường và bỏ qua khoảng trắng thừa
            return correctAnswerText.Trim().Equals(studentAnswerText.Trim(), StringComparison.OrdinalIgnoreCase);
        }
    }

    /// <summary>
    /// Kết quả chấm điểm bài thi
    /// </summary>
    public class ExamScoringResult
    {
        public int KetQuaId { get; set; }
        public int ExamId { get; set; }
        public string StudentId { get; set; } = string.Empty;
        public int TotalQuestions { get; set; }
        public int CorrectAnswers { get; set; }
        public double Score { get; set; }
        public List<QuestionScoringResult> QuestionResults { get; set; } = new List<QuestionScoringResult>();
    }

    /// <summary>
    /// Kết quả chấm điểm từng câu hỏi
    /// </summary>
    public class QuestionScoringResult
    {
        public int QuestionId { get; set; }
        public string QuestionType { get; set; } = string.Empty;
        public string QuestionContent { get; set; } = string.Empty;
        public bool IsCorrect { get; set; }
    }
}
