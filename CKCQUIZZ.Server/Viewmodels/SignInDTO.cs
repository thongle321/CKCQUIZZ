using System.ComponentModel.DataAnnotations;

namespace CKCQUIZZ.Server.Viewmodels;
    public class SignInDTO
    {
        [Required]
        public string Email { get; set; } = string.Empty;
        [Required]
        public string Password { get; set; } = string.Empty;
    }