namespace CKCQUIZZ.Server.Viewmodels.Lop
{
    public class ImportStudentDTO
    {
        public int TongSo { get; set; }
        public int SoHocSinhThemVaoLop { get; set; }
        public int SoHocSinhTaoTKMoi { get; set; }
        public List<string> Errors { get; set; } = [];
        public List<string> Warnings { get; set; } = [];
    }
}