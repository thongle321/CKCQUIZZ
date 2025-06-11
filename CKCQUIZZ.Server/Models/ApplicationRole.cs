using Microsoft.AspNetCore.Identity;

namespace CKCQUIZZ.Server.Models
{
    public partial class ApplicationRole : IdentityRole
    {
        public bool TrangThai { get; set; } = true;
        public bool ThamGiaThi { get; set; } = false;
        public bool ThamGiaHocPhan { get; set; } = false;

        public virtual ICollection<ChiTietQuyen> ChiTietQuyens { get; set; } = new List<ChiTietQuyen>();
    }
}