namespace CKCQUIZZ.Server.Viewmodels.DeThi
{
    public class ExamQuestionForStudentDto
    {
        public int Macauhoi { get; set; }
        public string NoiDung { get; set; } = null!;
        public string DoKho { get; set; } = null!;
        public string? HinhAnhUrl { get; set; }
        public string LoaiCauHoi { get; set; } = null!; // Thêm loại câu hỏi
        public List<ExamAnswerForStudentDto> CauTraLois { get; set; } = new List<ExamAnswerForStudentDto>();
    }

    public class ExamAnswerForStudentDto
    {
        public int Macautraloi { get; set; }
        public string NoiDung { get; set; } = null!;
        // Không trả về Ladapandung để tránh lộ đáp án
    }
}
