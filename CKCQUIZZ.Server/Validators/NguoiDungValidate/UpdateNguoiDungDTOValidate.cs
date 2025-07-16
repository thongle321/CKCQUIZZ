using System.Text.RegularExpressions;
using CKCQUIZZ.Server.Viewmodels.NguoiDung;
using FluentValidation;
using Microsoft.AspNetCore.Identity;
using CKCQUIZZ.Server.Models;
using Microsoft.EntityFrameworkCore;
namespace CKCQUIZZ.Server.Validators.NguoiDungValidate
{
    internal sealed partial class UpdateNguoiDungDTOValidate : AbstractValidator<UpdateNguoiDungRequestDTO>
    {
        private readonly UserManager<NguoiDung> _userManager;

        public UpdateNguoiDungDTOValidate(UserManager<NguoiDung> userManager)
        {
            _userManager = userManager;
            RuleFor(x => x.FullName)
            .NotEmpty().WithMessage("Họ tên là bắt buộc")
            .MaximumLength(40).WithMessage("Họ tên không được vướt quá 40 ký tự");

            RuleFor(x => x.Dob)
            .NotEmpty().WithMessage("Ngày sinh là bắt buộc.");

            RuleFor(x => x.PhoneNumber)
            .NotEmpty().WithMessage("Số điện thoại là bắt buộc")
            .MaximumLength(10).WithMessage("Số điện thoại không được vượt quá 10 ký tự.")
            .Matches(PhoneRegex()).WithMessage("Số điện thoại không đúng định dạng Việt Nam");

            RuleFor(x => x.Role)
            .NotEmpty().WithMessage("Quyền là bắt buộc");
            
        }

        [GeneratedRegex(@"^(03|05|07|08|09|01[2|6|8|9])([0-9]{8})$")]
        private static partial Regex PhoneRegex();
    }
}