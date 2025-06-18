namespace CKCQUIZZ.Server.Viewmodels.Lop
{
    /// <summary>
    /// DTO for pending request count
    /// </summary>
    public class PendingRequestCountDTO
    {
        /// <summary>
        /// Class ID
        /// </summary>
        public int Malop { get; set; }

        /// <summary>
        /// Number of pending join requests
        /// </summary>
        public int PendingCount { get; set; }
    }
}
