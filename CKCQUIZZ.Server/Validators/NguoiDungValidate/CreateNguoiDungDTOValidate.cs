using System.Text.RegularExpressions;
using CKCQUIZZ.Server.Viewmodels.NguoiDung;
using FluentValidation;
using Microsoft.AspNetCore.Identity;
using CKCQUIZZ.Server.Models;
namespace CKCQUIZZ.Server.Validators.NguoiDungValidate
{
    public partial class CreateNguoiDungDTOValidate : AbstractValidator<CreateNguoiDungRequestDTO>
    {

        public CreateNguoiDungDTOValidate(UserManager<NguoiDung> _userManager)
        {
            RuleFor(x => x.MSSV)
            .NotEmpty().WithMessage("MSSV là bắt buộc")
            .MinimumLength(6).WithMessage("Tối thiểu là 6 ký tự")
            .MaximumLength(10).WithMessage("Tối thiểu là 10 ký tự")
            .MustAsync(async (mssv, CancellationToken) => {
                return await _userManager.FindByIdAsync(mssv) == null;
            }).WithMessage("MSSV này đã tồn tại");


            RuleFor(x => x.UserName)
            .NotEmpty().WithMessage("Tên đăng nhập là bắt buộc")
            .Length(5, 30).WithMessage("Tên đăng nhập tối thiểu 5 và tối đa 30");

            RuleFor(x => x.Password)
            .NotEmpty().WithMessage("Mật khẩu là bắt buộc")
            .MinimumLength(8).WithMessage("Mật khẩu tối thiểu là 8 ký tự");


            RuleFor(x => x.Email)
            .NotEmpty().WithMessage("Email là bắt buộc")
            .MustAsync(async (email, CancellationToken) => {
                return await _userManager.FindByEmailAsync(email) == null;
            }).WithMessage("Email này đã tồn tại");

            RuleFor(x => x.Hoten)
            .NotEmpty().WithMessage("Họ tên là bắt buộc")
            .MaximumLength(40).WithMessage("Họ tên không được vướt quá 40 ký tự");

            RuleFor(x => x.Ngaysinh)
            .NotEmpty().WithMessage("Ngày sinh là bắt buộc.");

            RuleFor(x => x.PhoneNumber)
            .NotEmpty().WithMessage("Số điện thoại là bắt buộc")
            .MaximumLength(10).WithMessage("Số điện thoại không được vướt quá 10 ký tự.")
            .Matches(PhoneRegex()).WithMessage("Số điện thoại không hợp lệ");

            RuleFor(x => x.Role)
            .NotEmpty().WithMessage("Quyền là bắt buộc");
            
        }

        [GeneratedRegex(@"^(\+\d{1,2}\s?)?\(?\d{3}\)?[\s.-]?\d{3}[\s.-]?\d{4}$")]
        private static partial Regex PhoneRegex();
    }
}