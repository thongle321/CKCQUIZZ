using System.Collections.Generic;

namespace CKCQUIZZ.Server.Viewmodels.Student
{
    public class StudentExamDetailDto
    {
        public int Made { get; set; }
        public string Tende { get; set; } = null!;
        public int Thoigianthi { get; set; }
        public List<StudentQuestionDto> Questions { get; set; } = new List<StudentQuestionDto>();
    }
} 