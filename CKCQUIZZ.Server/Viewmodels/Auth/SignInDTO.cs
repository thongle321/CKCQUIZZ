using System.ComponentModel.DataAnnotations;

namespace CKCQUIZZ.Server.Viewmodels.Auth
{
    public class SignInDTO
    {
        [Required]
        public string Email { get; set; } = default!;
        [Required]
        public string Password { get; set; } = default!;
    }
}
