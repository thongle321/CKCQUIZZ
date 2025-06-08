using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace CKCQUIZZ.Server.Models
{
    public class DanhMucChucNang
    {

        public string ChucNang { get; set; } = default!;

        public string TenChucNang { get; set; } = default!;

        public ICollection<ChiTietQuyen> ChiTietQuyens { get; set; } = default!;
    }
}