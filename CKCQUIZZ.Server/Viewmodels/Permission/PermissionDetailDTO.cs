namespace CKCQUIZZ.Server.Viewmodels.Permission
{
    public class PermissionDetailDTO
    {
        public string ChucNang { get; set; } = default!;
        public string HanhDong { get; set; } = default!;
        public bool IsGranted { get; set; } 
    }
}