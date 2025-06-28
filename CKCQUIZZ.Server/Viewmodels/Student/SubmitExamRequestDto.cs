using System.Collections.Generic;

namespace CKCQUIZZ.Server.Viewmodels.Student
{
    public class SubmitExamRequestDto
    {
        public int KetQuaId { get; set; } // Thêm KetQuaId
        public int ExamId { get; set; }
        public List<AnswerSubmissionDto>? Answers { get; set; }
        public int? ThoiGianLamBai { get; set; }
    }
} 