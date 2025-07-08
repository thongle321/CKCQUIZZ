namespace CKCQUIZZ.Server.Viewmodels.NguoiDung
{
    public class GetNguoiDungDTO
    {
        public string MSSV { get; set; } = default!;
        public string Email { get; set; } = default!;
        public string Hoten { get; set; } = default!;
        public DateTime? Ngaysinh { get; set; }
        public string PhoneNumber { get; set; } = default!;
        public bool? Gioitinh { get; set; }
        public bool? Trangthai { get; set; }
        public string? CurrentRole { get; set; }
    }
}