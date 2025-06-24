using CKCQUIZZ.Server.Models;
using CKCQUIZZ.Server.Viewmodels;
using CKCQUIZZ.Server.Viewmodels.Lop;
using CKCQUIZZ.Server.Viewmodels.NguoiDung;

namespace CKCQUIZZ.Server.Interfaces
{
    public interface ILopService
    {
        Task<List<Lop>> GetAllAsync(string userId, bool? hienthi, string userRole);
        Task<Lop?> GetByIdAsync(int id);
        Task<Lop> CreateAsync(Lop lopModel, int mamonhoc, string giangvienId);
        Task<Lop?> UpdateAsync(int id, UpdateLopRequestDTO lopDTO);
        Task<Lop?> DeleteAsync(int id);
        Task<Lop?> ToggleStatusAsync(int id, bool status);

        Task<string?> RefreshInviteCodeAsync(int id);

        Task<PagedResult<GetNguoiDungDTO>> GetStudentsInClassAsync(int lopId, int pageNumber, int pageSize, string? searchQuery);

        Task<ChiTietLop?> AddStudentToClassAsync(int lopId, string manguoidungId);

        Task<bool> KickStudentFromClassAsync(int lopId, string manguoidungId);

        Task<List<MonHocWithNhomLopDTO>> GetSubjectsAndGroupsForTeacherAsync(string teacherId, bool? hienthi);

        // ===== JOIN REQUEST METHODS =====

        /// <summary>
        /// Student joins class by invite code (creates pending request)
        /// </summary>
        Task<ChiTietLop?> JoinClassByInviteCodeAsync(string inviteCode, string studentId);

        /// <summary>
        /// Get count of pending join requests for a class
        /// </summary>
        Task<int> GetPendingRequestCountAsync(int lopId);

        /// <summary>
        /// Get list of pending students for a class
        /// </summary>
        Task<List<PendingStudentDTO>> GetPendingStudentsAsync(int lopId);

        /// <summary>
        /// Approve a pending join request (set trangthai = true)
        /// </summary>
        Task<bool> ApproveJoinRequestAsync(int lopId, string studentId);

        /// <summary>
        /// Reject a pending join request (remove from database)
        /// </summary>
        Task<bool> RejectJoinRequestAsync(int lopId, string studentId);

        Task<List<GetNguoiDungDTO>> GetTeachersInClassAsync(int lopId);
    }

}

