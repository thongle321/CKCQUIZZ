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

        Task<List<MonHocWithNhomLopDTO>> GetSubjectsAndGroupsAsync(bool? hienthi);
        
        Task<List<MonHocWithNhomLopDTO>> GetSubjectsAndGroupsForTeacherAsync(string teacherId, bool? hienthi);

        Task<ChiTietLop?> JoinClassByInviteCodeAsync(string inviteCode, string studentId);
        Task<int> GetPendingRequestCountAsync(int lopId);

        Task<List<PendingStudentDTO>> GetPendingStudentsAsync(int lopId);

        Task<bool> ApproveJoinRequestAsync(int lopId, string studentId);

        Task<bool> RejectJoinRequestAsync(int lopId, string studentId);

        Task<List<GetNguoiDungDTO>> GetTeachersInClassAsync(int lopId);
        Task<byte[]?> ExportScoreboardPdfAsync(int lopId);
        Task<byte[]?> ExportStudentsToExcelAsync(int lopId);
    }

}

