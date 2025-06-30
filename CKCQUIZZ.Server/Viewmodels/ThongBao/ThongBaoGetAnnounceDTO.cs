namespace CKCQUIZZ.Server.Viewmodels.ThongBao
{
    public class ThongBaoGetAnnounceDTO
    {
        public int Matb { get; set; }
        public string? Avatar { get; set;}
        public string? Noidung { get; set; }
        public DateTime? Thoigiantao { get; set; }
        public string? Hoten { get; set; }
        public List<int>? Malops { get; set; }
    }
}