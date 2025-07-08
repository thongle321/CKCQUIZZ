namespace CKCQUIZZ.Server.Viewmodels.CauHoi
{
    public class KetQuaImportViewModel
    {
        public string ThongBao { get; set; } = default!;
        public int SoLuongThanhCong { get; set; }
        public int TongSoLuong { get; set; }
        public List<string> DanhSachLoi { get; set; } = [];
    }
}
