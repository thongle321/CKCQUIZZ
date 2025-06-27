using System.Collections.Generic;

namespace CKCQUIZZ.Server.Viewmodels.Student
{
    public class SubmitExamRequestDto
    {
        public int ExamId { get; set; }
        public List<AnswerSubmissionDto> Answers { get; set; } = new List<AnswerSubmissionDto>();
        public int? ThoiGianSoLamBai { get; set; }
    }
} 