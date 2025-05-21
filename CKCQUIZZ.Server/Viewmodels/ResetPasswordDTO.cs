using System.ComponentModel.DataAnnotations;

namespace CKCQUIZZ.Server.Viewmodels
{
    public class ResetPasswordDTO
    {
        [Required(ErrorMessage = "Email là bắt buộc")]
        [EmailAddress(ErrorMessage = "Định dạng Email không hợp lệ")]
        public string Email { get; set; }

        [Required(ErrorMessage = "Mã OTP là bắt buộc")]
        public string Otp { get; set; }

        [Required(ErrorMessage = "Mật khẩu mới là bắt buộc")]
        [StringLength(100, ErrorMessage = "{0} phải có ít nhất {2} ký tự.", MinimumLength = 6)] 
        [DataType(DataType.Password)]
        public string NewPassword { get; set; }
    }
}