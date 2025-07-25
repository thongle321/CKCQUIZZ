using CKCQUIZZ.Server.Viewmodels.PhanCong;
using CKCQUIZZ.Server.Viewmodels.MonHoc;
using Microsoft.AspNetCore.Mvc;

namespace CKCQUIZZ.Server.Interfaces
{
    public interface IPhanCongService
    {
        Task<List<PhanCongDTO>> GetAllAsync();
        Task<List<GetGiangVienDTO>> GetGiangVienAsync();
        Task<List<int>> AddAssignmentAsync(string giangvienId, List<int> listMaMonHoc);
        Task<bool> DeleteAssignmentAsync(int maMonHoc, string maNguoiDung);
        Task<bool> DeleteAllAssignmentsByUserAsync(string maNguoiDung);
        Task<List<PhanCongDTO>> GetAssignmentByUserAsync(string maNguoiDung);
        Task<List<MonHocDTO>> GetAssignedSubjectsAsync(string userId);
    }
}