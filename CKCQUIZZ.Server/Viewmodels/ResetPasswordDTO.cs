using System.ComponentModel.DataAnnotations;

namespace CKCQUIZZ.Server.Viewmodels
{
    public class ResetPasswordDTO
    {
        public string? Email { get; set; }

        [Required(ErrorMessage = "Token đặt lại mật khẩu là bắt buộc")]
        public string? Token { get; set; } 

        [Required(ErrorMessage = "Mật khẩu mới là bắt buộc")]
        [DataType(DataType.Password)]
        [MinLength(6, ErrorMessage = "Mật khẩu phải có ít nhất 6 ký tự")]
        public string? NewPassword { get; set; }

        [DataType(DataType.Password)]
        [Compare("NewPassword", ErrorMessage = "Mật khẩu mới và mật khẩu xác nhận không khớp.")]
        public string? ConfirmPassword { get; set; }
    }
}