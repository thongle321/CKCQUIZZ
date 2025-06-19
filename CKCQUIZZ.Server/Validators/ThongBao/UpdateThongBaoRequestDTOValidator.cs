using FluentValidation;
using CKCQUIZZ.Server.Viewmodels.ThongBao;

namespace CKCQUIZZ.Server.Validators.ThongBao
{
    public class UpdateThongBaoRequestDTOValidator : AbstractValidator<UpdateThongBaoRequestDTO>
    {
        public UpdateThongBaoRequestDTOValidator()
        {
            RuleFor(x => x.Noidung)
                .NotEmpty().WithMessage("Nội dung thông báo không được để trống.");

            RuleFor(x => x.Nguoitao)
                .NotEmpty().WithMessage("Người tạo không được để trống.");

            RuleFor(x => x.NhomIds)
                .NotEmpty().WithMessage("Danh sách nhóm không được để trống.")
                .Must(list => list.Any()).WithMessage("Thông báo phải được gửi đến ít nhất một nhóm.");
        }
    }
}