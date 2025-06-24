using CKCQUIZZ.Server.Viewmodels.Chuong;
using FluentValidation;

namespace CKCQUIZZ.Server.Validators.Chuong
{
    internal sealed class CreateChuongDTOValidate : AbstractValidator<CreateChuongRequestDTO>
    {
        public CreateChuongDTOValidate()
        {
            RuleFor(x => x.Tenchuong)
            .NotEmpty()
            .WithMessage("Tên chương là bắt buộc");
        }
    }
}