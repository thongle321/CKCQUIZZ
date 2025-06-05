namespace CKCQUIZZ.Server.Viewmodels.User
{
    public class CreateUserRequestDTO()
    {
        public string MSSV { get; set; } = default!;
        public string UserName {get; set;} = default!;
        public string Password { get; set; } = default!;
        public string Email { get; set; } = default!;
        public string FullName { get; set; } = default!;
        public DateTime Dob {get; set;}
        public string PhoneNumber { get; set; } = default!;
        public string Role { get; set; } = default!;
    }
}