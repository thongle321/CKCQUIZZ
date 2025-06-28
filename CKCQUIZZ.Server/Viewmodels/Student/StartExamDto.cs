namespace CKCQUIZZ.Server.Viewmodels.Student
{
    public class StartExamRequestDto
    {
        public int ExamId { get; set; }
    }

    public class StartExamResponseDto
    {
        public int KetQuaId { get; set; }
        public int ExamId { get; set; }
        public DateTime Thoigianbatdau { get; set; }
    }
}