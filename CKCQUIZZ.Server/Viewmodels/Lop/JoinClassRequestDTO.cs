namespace CKCQUIZZ.Server.Viewmodels.Lop
{
    /// <summary>
    /// DTO for student join class request by invite code
    /// </summary>
    public class JoinClassRequestDTO
    {
        /// <summary>
        /// Invite code of the class (mamoi)
        /// </summary>
        public string InviteCode { get; set; } = default!;
    }
}
