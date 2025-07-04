using System;
using System.Collections.Generic;

namespace CKCQUIZZ.Server.Viewmodels.Student
{
    public class ExamReviewDto
    {
        public double? Diem { get; set; }
        public int? SoCauDung { get; set; }
        public int? TongSoCau { get; set; }
        public bool Hienthibailam { get; set; }
        public bool Xemdapan { get; set; }
        public bool Xemdiemthi { get; set; }
        public List<ExamReviewQuestionDto> Questions { get; set; } = [];
        public Dictionary<int, object> CorrectAnswers { get; set; } = [];
    }

    public class ExamReviewQuestionDto
    {
        public int Macauhoi { get; set; }
        public string Noidung { get; set; } = default!;
        public string Loaicauhoi { get; set; } = default!;
        public string Hinhanhurl { get; set; } = default!;
        public List<ExamReviewAnswerOptionDto> Answers { get; set; } = [];
        public int? StudentSelectedAnswerId { get; set; }
        public List<int> StudentSelectedAnswerIds { get; set; } = [];
        public string StudentAnswerText { get; set; } = default!;
    }

    public class ExamReviewAnswerOptionDto
    {
        public int Macautl { get; set; }
        public string Noidungtl { get; set; } = default!;
        public bool Dapan { get; set; }
    }
}