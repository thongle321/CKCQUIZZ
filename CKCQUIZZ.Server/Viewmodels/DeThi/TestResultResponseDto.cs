namespace CKCQUIZZ.Server.Viewmodels.DeThi
{
    public class TestResultResponseDto
    {
        public TestInfoDto DeThiInfo { get; set; } = default!;
        public IEnumerable<LopInfoDto> Lops { get; set; } = [];
        public IEnumerable<StudentResultDto> Results { get; set; } = [];
    }
    public class TestInfoDto
    {
        public int Made { get; set; }
        public string Tende { get; set; } = default!;
        public string TenMonHoc { get; set; } = default!;
    }

    public class LopInfoDto
    {
        public int Malop { get; set; }
        public string Tenlop { get; set; } = default!;
    }

    public class StudentResultDto
    {
        public string Mssv { get; set; } = default!;
        public string Ho { get; set; } = default!;
        public string Ten { get; set; } = default!;
        public double? Diem { get; set; }
        public DateTime? ThoiGianVaoThi { get; set; }
        public int? ThoiGianThi { get; set; }
        public int Solanthoat { get; set; }
        public string TrangThai { get; set; } = default!;
        public int Malop { get; set; }
    }
}
