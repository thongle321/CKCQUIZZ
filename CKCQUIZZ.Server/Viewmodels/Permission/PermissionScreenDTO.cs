namespace CKCQUIZZ.Server.Viewmodels.Permission
{
    public class PermissionScreenDTO
    {
        public string Id { get; set; } = default!;
        public string TenNhomQuyen { get; set; } = default!;
        public bool ThamGiaThi { get; set; } 
        public bool ThamGiaHocPhan { get; set; }

        public List<PermissionDetailDTO> Permissions { get; set; } = default!;
    }

}