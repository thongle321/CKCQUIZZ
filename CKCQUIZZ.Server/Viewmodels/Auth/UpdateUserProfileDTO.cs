namespace CKCQUIZZ.Server.Viewmodels.Auth
{
    public class UpdateUserProfileDTO
    {
        public string Fullname { get; set; } = default!;
        public string Email { get; set; } = default!;
        public bool Gender { get; set; }
        public DateTime? Dob { get; set; }
        public string PhoneNumber { get; set; } = default!;
        public string Avatar { get; set; } = default!;
    }
}