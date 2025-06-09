namespace CKCQUIZZ.Server.Models
{
    public partial class ChiTietQuyen
    {
        public string RoleId { get; set; } = default!;

        public string ChucNang { get; set; } = default!;

        public string HanhDong { get; set; } = default!;

        public virtual ApplicationRole RoleidNavigation { get; set; } = default!;

        public DanhMucChucNang DanhMucChucNang { get; set; } = default!;
    }
}