namespace CKCQUIZZ.Server.Viewmodels.NguoiDung
{
    public class CreateNguoiDungRequestDTO()
    {
        public string MSSV { get; set; } = default!;
        public string UserName {get; set;} = default!;
        public string Password { get; set; } = default!;
        public string Email { get; set; } = default!;
        public string Hoten { get; set; } = default!;
        public DateTime Ngaysinh {get; set;}
        public string PhoneNumber { get; set; } = default!;
        public string Role { get; set; } = default!;
    }
}