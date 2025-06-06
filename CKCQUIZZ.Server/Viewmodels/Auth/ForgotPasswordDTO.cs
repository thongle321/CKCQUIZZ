using System.ComponentModel.DataAnnotations;

namespace CKCQUIZZ.Server.Viewmodels.Auth
{
    public class ForgotPasswordDTO
    {
        [Required]
        [EmailAddress(ErrorMessage = "Định dạng Email không hợp lệ")]
        public string Email { get; set; } = default!;
    }
}