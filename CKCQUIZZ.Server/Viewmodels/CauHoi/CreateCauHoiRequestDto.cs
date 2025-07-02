using System.ComponentModel.DataAnnotations;

namespace CKCQUIZZ.Server.Viewmodels.CauHoi
{
    public class CreateCauHoiRequestDto
    {
        [Required(ErrorMessage = "Nội dung câu hỏi không được để trống")]
        public string Noidung { get; set; } = default!;
        public int Dokho { get; set; }
        [Range(1, int.MaxValue, ErrorMessage = "Vui lòng chọn môn học")]
        public int Mamonhoc { get; set; }
        [Range(1, int.MaxValue, ErrorMessage = "Vui lòng chọn chương")]
        public int Machuong { get; set; }
        public bool? Daodapan { get; set; }
        public string Loaicauhoi { get; set; } = string.Empty;
        public string? Hinhanhurl { get; set; }
        [Required(ErrorMessage = "Câu hỏi phải có đáp án.")]
        public List<CreateCauTraLoiDto> CauTraLois { get; set; } = [];
    }
}
