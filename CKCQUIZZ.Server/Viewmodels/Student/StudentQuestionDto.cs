using System.Collections.Generic;

namespace CKCQUIZZ.Server.Viewmodels.Student
{
    public class StudentQuestionDto
    {
        public int Macauhoi { get; set; }
        public string Noidung { get; set; } = null!;
        public string Loaicauhoi { get; set; } = null!;
        public string? Hinhanhurl { get; set; }
        public List<StudentAnswerDto> Answers { get; set; } = [];
    }
} 