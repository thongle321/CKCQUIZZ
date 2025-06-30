using System.ComponentModel.DataAnnotations;

namespace CKCQUIZZ.Server.Viewmodels.Auth
{
    public class SignInDTO
    {
        public string Email { get; set; } = default!;
        public string Password { get; set; } = default!;
    }
}
