namespace CKCQUIZZ.Server.Viewmodels.Lop
{
    public class GetLopSinhVienDTO
    {
        public string MSSV { get; set; } = default!;
        public string Hoten { get; set; } = default!;
        public DateTime? Ngaysinh { get; set; }
        public string PhoneNumber { get; set; } = default!;
        public bool? Gioitinh { get; set; }
    }
}