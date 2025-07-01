using System;
using System.Collections.Generic;

namespace CKCQUIZZ.Server.Viewmodels.Student
{
    public class ExamReviewDto
    {
        public double? Diem { get; set; }
        public int? SoCauDung { get; set; }
        public int? TongSoCau { get; set; }
        public List<ExamReviewQuestionDto> Questions { get; set; } = new List<ExamReviewQuestionDto>();
        public Dictionary<int, object> CorrectAnswers { get; set; } // Key: Macauhoi, Value: Macautl (for MC/SC) or Noidungtl (for Essay)
    }

    public class ExamReviewQuestionDto
    {
        public int Macauhoi { get; set; }
        public string Noidung { get; set; }
        public string Loaicauhoi { get; set; }
        public string Hinhanhurl { get; set; }
        public List<ExamReviewAnswerOptionDto> Answers { get; set; } = new List<ExamReviewAnswerOptionDto>();
        public int? StudentSelectedAnswerId { get; set; } // For single_choice
        public List<int> StudentSelectedAnswerIds { get; set; } = new List<int>(); // For multiple_choice
        public string StudentAnswerText { get; set; } // For essay
    }

    public class ExamReviewAnswerOptionDto
    {
        public int Macautl { get; set; }
        public string Noidungtl { get; set; }
        public bool Dapan { get; set; } // Indicates if this is a correct answer
    }
}