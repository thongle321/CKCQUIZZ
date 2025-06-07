using System.Data;
using System.Text.RegularExpressions;
using CKCQUIZZ.Server.Viewmodels.NguoiDung;
using FluentValidation;

namespace CKCQUIZZ.Server.Validators.NguoiDung
{
    public partial class CreateNguoiDungDTOValidate : AbstractValidator<CreateNguoiDungRequestDTO>
    {
        public CreateNguoiDungDTOValidate()
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

            RuleFor(x => x.Hoten)
            .NotEmpty().WithMessage("Họ tên là bắt buộc")
            .MaximumLength(40).WithMessage("Họ tên không được vướt quá 40 ký tự");

            RuleFor(x => x.Ngaysinh)
            .Must(ValidDate).WithMessage("Ngày sinh là bắt buộc");

            RuleFor(x => x.PhoneNumber)
            .NotEmpty().WithMessage("Số điện thoại là bắt buộc")
            .MaximumLength(10).WithMessage("Số điện thoại không được vướt quá 10 ký tự.")
            .Matches(MyRegex()).WithMessage("Số điện thoại không hợp lệ");

            RuleFor(x => x.Role)
            .NotEmpty().WithMessage("Quyền là bắt buộc");
        }
        private bool ValidDate(DateTime date)
        {
            return !date.Equals(default);
        }

        [GeneratedRegex(@"^(\+\d{1,2}\s?)?\(?\d{3}\)?[\s.-]?\d{3}[\s.-]?\d{4}$")]
        private static partial Regex MyRegex();
    }
}