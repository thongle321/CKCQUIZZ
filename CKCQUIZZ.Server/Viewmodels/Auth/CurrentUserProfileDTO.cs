namespace CKCQUIZZ.Server.Viewmodels.Auth
{
    public class CurrentUserProfileDTO
    {
        public string Mssv { get; set; } = default!;
        public string Avatar { get; set; } = default!;
        public string Fullname { get; set; } = default!;
        public string Email { get; set; } = default!;
        public string Phonenumber { get; set; } = default!;
        public bool? Gender { get; set; } 
        public DateTime? Dob { get; set; }
        public IList<string> Roles { get; set; } = default!;
    }
}