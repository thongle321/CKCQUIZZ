using CKCQUIZZ.Server.Viewmodels.Auth;
using FluentValidation;

namespace CKCQUIZZ.Server.Validators.Auth
{
    internal sealed class SignInDTOValidate : AbstractValidator<SignInDTO>
    {
        public SignInDTOValidate()
        {
            RuleFor(x => x.Email)
            .NotEmpty()
            .WithMessage("Email là bắt buộc");
            RuleFor(x => x.Password)
            .MinimumLength(8).WithMessage("Mật khẩu tối thiểu là 8 ký tự")
            .NotEmpty().WithMessage("Mật khẩu là bắt buộc");
        }
    }
}