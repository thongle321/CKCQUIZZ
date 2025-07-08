namespace CKCQUIZZ.Server.Viewmodels.NguoiDung
{
    public class UpdateNguoiDungRequestDTO
    {
        public string Email { get; set; } = default!;
        public string FullName { get; set; } = default!;
        public DateTime Dob { get; set; }
        public string PhoneNumber { get; set; } = default!;
        public bool Status {get; set;}
        public bool Gioitinh {get; set;}
        public string Role { get; set; } = default!;
    }
}