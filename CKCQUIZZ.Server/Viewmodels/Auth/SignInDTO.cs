using System.ComponentModel.DataAnnotations;

namespace CKCQUIZZ.Server.Viewmodels.Auth
{
    public class SignInDTO
    {
        [Required(ErrorMessage = "Email là bắt buộc")]
        public string Email { get; set; } = default!;
        [Required(ErrorMessage = "Mật khẩu là bắt buộc")]
        public string Password { get; set; } = default!;
    }
}
