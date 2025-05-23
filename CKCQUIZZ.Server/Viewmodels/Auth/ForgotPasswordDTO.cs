using System.ComponentModel.DataAnnotations;

namespace CKCQUIZZ.Server.Viewmodels
{
    public class ForgotPasswordDTO
    {
        [Required]
        [EmailAddress(ErrorMessage = "Định dạng Email không hợp lệ")]
        public string Email { get; set; } = string.Empty;
    }
}