using FluentValidation;
using CKCQUIZZ.Server.Viewmodels.DeThi;

namespace CKCQUIZZ.Server.Validators.DeThi
{
    public class CreateDeThiDTOValidator : AbstractValidator<DeThiCreateRequest>
    {
        public CreateDeThiDTOValidator()
        {
            RuleFor(x => x.Tende)
                .NotEmpty().WithMessage("Tên đề thi không được để trống.")
                .MaximumLength(255).WithMessage("Tên đề thi không được vượt quá 255 ký tự.");

            RuleFor(x => x.Thoigianbatdau)
                .NotEmpty().WithMessage("Thời gian bắt đầu không được để trống.")
                .Must(ValidateStartTime).WithMessage("Thời gian bắt đầu không được nhỏ hơn ngày hiện tại.");

            RuleFor(x => x.Thoigianketthuc)
                .NotEmpty().WithMessage("Thời gian kết thúc không được để trống.")
                .GreaterThan(x => x.Thoigianbatdau).WithMessage("Thời gian kết thúc phải sau thời gian bắt đầu.");

            RuleFor(x => x.Thoigianthi)
                .GreaterThan(0).WithMessage("Thời gian thi phải lớn hơn 0.");

            RuleFor(x => x.Monthi)
                .GreaterThan(0).WithMessage("Môn thi không hợp lệ.");

            RuleFor(x => x.Malops)
                .NotEmpty().WithMessage("Phải chọn ít nhất một lớp để giao đề thi.");

            When(x => x.Loaide == 1, () =>
            {
                RuleFor(x => x.Machuongs)
                    .NotEmpty().WithMessage("Phải chọn ít nhất một chương khi loại đề là tự động.");
                RuleFor(x => x.Socaude)
                    .GreaterThanOrEqualTo(0).WithMessage("Số câu dễ không được âm.");
                RuleFor(x => x.Socautb)
                    .GreaterThanOrEqualTo(0).WithMessage("Số câu trung bình không được âm.");
                RuleFor(x => x.Socaukho)
                    .GreaterThanOrEqualTo(0).WithMessage("Số câu khó không được âm.");
                RuleFor(x => x.Socaude + x.Socautb + x.Socaukho)
                    .GreaterThan(0).WithMessage("Tổng số câu hỏi phải lớn hơn 0.");
            });
        }

        private bool ValidateStartTime(DateTime thoigianbatdau)
        {
            return thoigianbatdau.ToUniversalTime() >= DateTime.UtcNow;
        }
    }
}