namespace CKCQUIZZ.Server.Viewmodels.Student
{
    public class RecalculateScoresRequestDto
    {
        public int? ExamId { get; set; } // null = recalculate all exams
    }

    public class RecalculateScoresResponseDto
    {
        public int ProcessedExams { get; set; }
        public int FixedResults { get; set; }
        public List<string> Issues { get; set; } = new List<string>();
        public string Message { get; set; } = string.Empty;
    }
}
