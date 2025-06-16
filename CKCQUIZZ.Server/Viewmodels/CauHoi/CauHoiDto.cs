    namespace CKCQUIZZ.Server.Viewmodels.CauHoi
{
    public class CauHoiDto
    {
        public int Macauhoi { get; set; }
        public string Noidung { get; set; } = string.Empty;
        public string TenMonHoc { get; set; } = string.Empty;
        public string TenChuong { get; set; } = string.Empty;
        public string TenDoKho { get; set; } = string.Empty;
        public bool Trangthai { get; set; }
        public string Loaicauhoi { get; set; } = string.Empty;
        public string? Hinhanhurl { get; set; }
    }
}
