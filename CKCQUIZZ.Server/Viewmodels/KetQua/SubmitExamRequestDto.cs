using System.ComponentModel.DataAnnotations;

namespace CKCQUIZZ.Server.Viewmodels.KetQua
{
    public class SubmitExamRequestDto
    {
        [Required(ErrorMessage = "Mã đề thi là bắt buộc")]
        public int Made { get; set; }

        [Required(ErrorMessage = "Mã người dùng là bắt buộc")]
        public string Manguoidung { get; set; } = null!;

        [Required(ErrorMessage = "Thời gian bắt đầu là bắt buộc")]
        public DateTime Thoigianbatdau { get; set; }

        [Required(ErrorMessage = "Thời gian kết thúc là bắt buộc")]
        public DateTime Thoigianketthuc { get; set; }

        [Required(ErrorMessage = "Chi tiết trả lời là bắt buộc")]
        public List<StudentAnswerDto> ChiTietTraLoi { get; set; } = new List<StudentAnswerDto>();
    }

    public class StudentAnswerDto
    {
        [Required(ErrorMessage = "Mã câu hỏi là bắt buộc")]
        public int Macauhoi { get; set; }

        /// <summary>
        /// Mã câu trả lời được chọn (null nếu không chọn) - Single choice
        /// </summary>
        public int? Macautraloi { get; set; }

        /// <summary>
        /// Danh sách mã câu trả lời được chọn - Multiple choice
        /// </summary>
        public List<int>? DanhSachMacautraloi { get; set; }

        /// <summary>
        /// Câu trả lời tự luận - Essay
        /// </summary>
        public string? CauTraLoiTuLuan { get; set; }

        /// <summary>
        /// Thời gian trả lời câu hỏi
        /// </summary>
        public DateTime? Thoigiantraloi { get; set; }
    }
}
