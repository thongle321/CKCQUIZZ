namespace CKCQUIZZ.Server.Viewmodels.ThongBao
{
    public class CreateThongBaoRequestDTO
    {
        public string? Noidung { get; set; }

        public DateTime? Thoigiantao { get; set; }

        public List<int> NhomIds { get; set; } = new List<int>();
    }
}