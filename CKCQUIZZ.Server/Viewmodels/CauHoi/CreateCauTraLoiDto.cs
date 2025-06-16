using System.ComponentModel.DataAnnotations;

namespace CKCQUIZZ.Server.Viewmodels.CauHoi
{
    public class CreateCauTraLoiDto
    {
        [Required(ErrorMessage = "Nội dung câu trả lời không được để trống")]   
        public string Noidungtl { get; set; }
        public bool Dapan { get; set; }
    }
}
