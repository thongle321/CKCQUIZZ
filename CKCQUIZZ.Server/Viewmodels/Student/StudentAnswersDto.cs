namespace CKCQUIZZ.Server.Viewmodels.Student
{
    public class StudentAnswersDto
    {
        public List<DapAnSinhVienDto> DapAnSinhViens { get; set; } = new List<DapAnSinhVienDto>();
    }

    public class DapAnSinhVienDto
    {
        public int Macauhoi { get; set; }
        public int? Macautl { get; set; }
        public int? Dapansv { get; set; }
        public string? Dapantuluansv { get; set; }
    }
}
