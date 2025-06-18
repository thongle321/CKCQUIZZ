using FluentValidation;
using CKCQUIZZ.Server.Viewmodels.ThongBao;

namespace CKCQUIZZ.Server.Validators.ThongBao
{
    public class CreateThongBaoRequestDTOValidator : AbstractValidator<CreateThongBaoRequestDTO>
    {
        public CreateThongBaoRequestDTOValidator()
        {
            RuleFor(x => x.Noidung)
                .NotEmpty().WithMessage("Nội dung thông báo không được để trống.");


            RuleFor(x => x.NhomIds)
                .NotEmpty().WithMessage("Danh sách nhóm không được để trống.")
                .Must(list => list.Any()).WithMessage("Thông báo phải được gửi đến ít nhất một nhóm.");
        }
    }
}