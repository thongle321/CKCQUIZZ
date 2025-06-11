using CKCQUIZZ.Server.Models;
using CKCQUIZZ.Server.Viewmodels.Lop;

namespace CKCQUIZZ.Server.Interfaces
{
    public interface ILopService
    {
        Task<List<Lop>> GetAllAsync(string giangvienId, bool? hienthi);
        Task<Lop?> GetByIdAsync(int id);
        Task<Lop> CreateAsync(Lop lopModel, int mamonhoc, string giangvienId);
        Task<Lop?> UpdateAsync(int id, UpdateLopRequestDTO lopDTO);
        Task<Lop?> DeleteAsync(int id);
        Task<Lop?> ToggleStatusAsync(int id, bool status);

        // Tương đương updateInvitedCode()
        Task<string?> RefreshInviteCodeAsync(int id);

        // Tương đương getSvList()
        Task<IEnumerable<NguoiDung>> GetStudentsInClassAsync(int lopId);

        // Tương đương addSvGroup()
        Task<ChiTietLop?> AddStudentToClassAsync(int lopId, string manguoidungId);

        // Tương đương kickUser()
        Task<bool> KickStudentFromClassAsync(int lopId, string manguoidungId);
    }

}

