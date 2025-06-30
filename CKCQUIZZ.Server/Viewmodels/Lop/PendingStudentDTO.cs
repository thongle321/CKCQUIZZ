namespace CKCQUIZZ.Server.Viewmodels.Lop
{

    public class PendingStudentDTO
    {
        public string Manguoidung { get; set; } = default!;

        public string Hoten { get; set; } = default!;

        public string Email { get; set; } = default!;

        public string Mssv { get; set; } = default!;

        public DateTime? NgayYeuCau { get; set; }
    }
}
