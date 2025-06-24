using CKCQUIZZ.Server.Viewmodels.Chuong;
using FluentValidation;

namespace CKCQUIZZ.Server.Validators.Chuong
{
    internal sealed class UpdateChuongDTOValidate : AbstractValidator<UpdateChuongResquestDTO>
    {
        public UpdateChuongDTOValidate()
        {
            RuleFor(x => x.Tenchuong)
            .NotEmpty()
            .WithMessage("Tên chương là bắt buộc");
        }
    }
}