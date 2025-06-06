using System.ComponentModel.DataAnnotations;
namespace CKCQUIZZ.Server.Viewmodels.Chuong
{
    public class UpdateChuongResquestDTO
    {

        public string Tenchuong { get; set; } = null!;

        public int Mamonhoc { get; set; }

        public bool? Trangthai { get; set; }
    }
}
