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
            .MinimumLength(8)
            .NotEmpty().WithMessage("Mật khẩu là bắt buộc");
        }
    }
}