using System.Collections.Generic;

namespace CKCQUIZZ.Server.Viewmodels.Dashboard
{
    public class DashboardStatisticsDto
    {
        public int TotalUsers { get; set; }
        public int TotalStudents { get; set; }
        public int TotalSubjects { get; set; }
        public int TotalQuestions { get; set; }
        public int TotalExams { get; set; }
        public int ActiveExams { get; set; }
        public int CompletedExams { get; set; }
        public Dictionary<string, int> MonthlyUserRegistrations { get; set; } = new Dictionary<string, int>();
        public Dictionary<string, int> ExamCompletionRates { get; set; } = new Dictionary<string, int>();
    }
}