using System.Text.RegularExpressions;
using CKCQUIZZ.Server.Viewmodels.NguoiDung;
using FluentValidation;
using Microsoft.AspNetCore.Identity;
using CKCQUIZZ.Server.Models;
using Microsoft.EntityFrameworkCore;
namespace CKCQUIZZ.Server.Validators.NguoiDungValidate
{
    internal sealed partial class CreateNguoiDungDTOValidate : AbstractValidator<CreateNguoiDungRequestDTO>
    {

        public CreateNguoiDungDTOValidate(UserManager<NguoiDung> _userManager)
        {
            RuleFor(x => x.MSSV)
            .NotEmpty().WithMessage("MSSV là bắt buộc")
            .MinimumLength(6).WithMessage("Tối thiểu là 6 ký tự")
            .MaximumLength(10).WithMessage("Tối thiểu là 10 ký tự")
            .Matches(@"^\d+$").WithMessage("MSSV chỉ có thể chứa chữ số.")
            .MustAsync(async (mssv, CancellationToken) => {
                return await _userManager.FindByIdAsync(mssv) == null;
            }).WithMessage("MSSV này đã tồn tại");

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
            .MaximumLength(10).WithMessage("Số điện thoại không được vượt quá 10 ký tự.")
            .Matches(PhoneRegex()).WithMessage("Số điện thoại không đúng định dạng Việt Nam")
            .MustAsync(async (phoneNumber, cancellationToken) => {
                var existingUser = await _userManager.Users.FirstOrDefaultAsync(u => u.PhoneNumber == phoneNumber, cancellationToken);
                return existingUser == null;
            }).WithMessage("Số điện thoại này đã tồn tại");

            RuleFor(x => x.Role)
            .NotEmpty().WithMessage("Quyền là bắt buộc");
            
        }

        [GeneratedRegex(@"^(03|05|07|08|09|01[2|6|8|9])([0-9]{8})$")]
        private static partial Regex PhoneRegex();
    }
}