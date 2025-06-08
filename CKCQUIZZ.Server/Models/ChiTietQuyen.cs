namespace CKCQUIZZ.Server.Models
{
    public class ChiTietQuyen
    {
        public string RoleId { get; set; } = default!;

        public string ChucNang { get; set; } = default!;

        public string HanhDong { get; set; } = default!;

        public virtual ApplicationRole ApplicationRole { get; set; } = default!;

        public DanhMucChucNang DanhMucChucNang { get; set; } = default!;
    }
}