namespace CKCQUIZZ.Server.Viewmodels.Lop
{
    /// <summary>
    /// DTO for pending student join requests
    /// </summary>
    public class PendingStudentDTO
    {
        /// <summary>
        /// Student ID (MSSV)
        /// </summary>
        public string Manguoidung { get; set; } = default!;

        /// <summary>
        /// Student full name
        /// </summary>
        public string Hoten { get; set; } = default!;

        /// <summary>
        /// Student email
        /// </summary>
        public string Email { get; set; } = default!;

        /// <summary>
        /// Student MSSV
        /// </summary>
        public string Mssv { get; set; } = default!;

        /// <summary>
        /// Date when join request was made
        /// </summary>
        public DateTime? NgayYeuCau { get; set; }
    }
}
