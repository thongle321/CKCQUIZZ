using CKCQUIZZ.Server.Viewmodels.MonHoc;
using FluentValidation;

namespace CKCQUIZZ.Server.Validators.MonHoc
{
    internal sealed class CreateMonHocDTOValidate : AbstractValidator<CreateMonHocRequestDTO>
    {
        public CreateMonHocDTOValidate()
        {
            RuleFor(x => x.Mamonhoc)
                .NotEmpty().WithMessage("Mã môn học là bắt buộc và không được là 0.")
                .GreaterThan(0).WithMessage("Mã môn học phải là một số dương.");

            RuleFor(x => x.Tenmonhoc)
                .NotEmpty().WithMessage("Tên môn học là bắt buộc.")
                .MinimumLength(3).WithMessage("Tên môn học phải có ít nhất 3 ký tự")
                .MaximumLength(100).WithMessage("Tên môn học không được vượt quá 100 ký tự.");

            RuleFor(x => x.Sotinchi)
                .NotEmpty().WithMessage("Số tín chỉ là bắt buộc và không được là 0.")
                .GreaterThan(0).WithMessage("Số tín chỉ phải là một số dương.")
                .LessThanOrEqualTo(15).WithMessage("Số tín chỉ không được vượt quá 15.");

            RuleFor(x => x.Sotietlythuyet)
                .GreaterThanOrEqualTo(0).WithMessage("Số tiết lý thuyết không được là số âm.")
                .LessThanOrEqualTo(120).WithMessage("Số tiết lý thuyết không được vượt quá 120.");

            RuleFor(x => x.Sotietthuchanh)
                .GreaterThanOrEqualTo(0).WithMessage("Số tiết thực hành không được là số âm.")
                .LessThanOrEqualTo(120).WithMessage("Số tiết thực hành không được vượt quá 120.");
        }
    }
}