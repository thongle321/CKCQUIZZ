namespace CKCQUIZZ.Server.Viewmodels.Permission
{
    public class PermissionScreenDTO
    {
        public string Maquyen { get; set; } = default!;

        public string Ten { get; set; } = default!;

        public bool QuyenTao { get; set; }

        public bool QuyenCapNhat { get; set; }

        public bool QuyenXoa { get; set; }

        public bool QuyenXem { get; set; }
    }

}

