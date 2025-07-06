using System.ComponentModel.DataAnnotations;

namespace CKCQUIZZ.Server.Viewmodels.KetQua
{
    public class UpdateScoreRequestDto
    {
        [Required(ErrorMessage = "ExamId là bắt buộc")]
        public int ExamId { get; set; }

        [Required(ErrorMessage = "StudentId là bắt buộc")]
        public string StudentId { get; set; } = string.Empty;

        [Required(ErrorMessage = "NewScore là bắt buộc")]
        [Range(0, 10, ErrorMessage = "Điểm phải từ 0 đến 10")]
        public double NewScore { get; set; }
    }
}
