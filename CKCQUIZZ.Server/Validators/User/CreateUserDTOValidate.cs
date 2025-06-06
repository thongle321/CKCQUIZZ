using System.Data;
using System.Text.RegularExpressions;
using CKCQUIZZ.Server.Viewmodels.User;
using FluentValidation;

namespace CKCQUIZZ.Server.Validators.User
{
    public class CreateUserDTOValidate : AbstractValidator<CreateUserRequestDTO>
    {
        public CreateUserDTOValidate()
        {
            RuleFor(x => x.MSSV)
            .NotEmpty().WithMessage("MSSV là bắt buộc")
            .MinimumLength(10).WithMessage("Tối thiểu là 10 ký tự")
            .MaximumLength(10).WithMessage("Tối thiểu là 10 ký tự");

            RuleFor(x => x.UserName)
            .NotEmpty().WithMessage("Tên đăng nhập là bắt buộc")
            .Length(5, 30).WithMessage("Tên đăng nhập tối thiểu 5 và tối đa 30");

            RuleFor(x => x.Password)
            .NotEmpty().WithMessage("Mật khẩu là bắt buộc")
            .MinimumLength(8).WithMessage("Mật khẩu tối thiểu là 8 ký tự");
            

            RuleFor(x => x.Email)
            .NotEmpty().WithMessage("Email là bắt buộc");

            RuleFor(x => x.FullName)
            .NotEmpty().WithMessage("Họ tên là bắt buộc")
            .MaximumLength(40).WithMessage("Họ tên không được vướt quá 40 ký tự");

            RuleFor(x => x.Dob)
            .Must(ValidDate).WithMessage("Ngày sinh là bắt buộc");

            RuleFor(x => x.PhoneNumber)
            .NotEmpty().WithMessage("Số điện thoại là bắt buộc")
            .MaximumLength(10).WithMessage("Số điện thoại không được vướt quá 10 ký tự.")
            .Matches(new Regex(@"^(\+\d{1,2}\s?)?\(?\d{3}\)?[\s.-]?\d{3}[\s.-]?\d{4}$")).WithMessage("Số điện thoại không hợp lệ");

            RuleFor(x => x.Role)
            .NotEmpty().WithMessage("Quyền là bắt buộc");
        }
        private bool ValidDate(DateTime date)
        {
            return !date.Equals(default(DateTime));
        }
    }
}