using System.Text.RegularExpressions;
using CKCQUIZZ.Server.Viewmodels.NguoiDung;
using FluentValidation;
using Microsoft.AspNetCore.Identity;
using CKCQUIZZ.Server.Models;
namespace CKCQUIZZ.Server.Validators.NguoiDungValidate
{
    internal sealed partial class UpdateNguoiDungDTOValidate : AbstractValidator<UpdateNguoiDungRequestDTO>
    {

        public UpdateNguoiDungDTOValidate()
        {
            RuleFor(x => x.FullName)
            .NotEmpty().WithMessage("Họ tên là bắt buộc")
            .MaximumLength(40).WithMessage("Họ tên không được vướt quá 40 ký tự");

            RuleFor(x => x.Dob)
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