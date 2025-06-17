namespace CKCQUIZZ.Server.Viewmodels.ThongBao
{
    public class UpdateThongBaoRequestDTO
    {
        public string? Noidung { get; set; }

        public DateTime? Thoigiantao { get; set; }

        public string Nguoitao { get; set; } = default!;
        public List<int> NhomIds { get; set; } = new List<int>();
    }
}