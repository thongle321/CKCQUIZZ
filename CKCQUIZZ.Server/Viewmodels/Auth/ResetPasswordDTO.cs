using System.ComponentModel.DataAnnotations;

namespace CKCQUIZZ.Server.Viewmodels.Auth
{
    public class ResetPasswordDTO
    {
        [Required]
        public string Email { get; set; } = default!;

        [Required]
        public string Token { get; set; } = default!;

        [Required(ErrorMessage = "Mật khẩu mới là bắt buộc")]
        [DataType(DataType.Password)]
        [MinLength(6, ErrorMessage = "Mật khẩu phải có ít nhất 6 ký tự")]
        public string NewPassword { get; set; } = default!;

        [DataType(DataType.Password)]
        [Compare("NewPassword", ErrorMessage = "Mật khẩu mới và mật khẩu xác nhận không khớp.")]
        public string ConfirmPassword { get; set; } = default!;
    }
}