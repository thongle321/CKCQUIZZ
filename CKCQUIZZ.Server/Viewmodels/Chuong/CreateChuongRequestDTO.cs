using System.ComponentModel.DataAnnotations;
namespace CKCQUIZZ.Server.Viewmodels.Chuong
{
    public class CreateChuongRequestDTO
    {
        
        public string Tenchuong { get; set; } = null!;

        public int Mamonhoc { get; set; }

        public bool? Trangthai { get; set; } = true;
    }
}
