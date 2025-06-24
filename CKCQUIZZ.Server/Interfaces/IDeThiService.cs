using CKCQUIZZ.Server.Viewmodels.DeThi;

namespace CKCQUIZZ.Server.Interfaces
{
    public interface IDeThiService
    {
        Task<List<DeThiViewModel>> GetAllAsync();
        Task<DeThiDetailViewModel> GetByIdAsync(int id);
        Task<DeThiViewModel> CreateAsync(DeThiCreateRequest request);
        Task<bool> UpdateAsync(int id, DeThiUpdateRequest request);
        Task<bool> DeleteAsync(int id);
        Task<bool> CapNhatChiTietDeThiAsync(int maDe, CapNhatChiTietDeThiRequest request);
        Task<IEnumerable<ExamForClassDto>> GetExamsForClassAsync(int classId, string studentId);
        Task<IEnumerable<ExamForClassDto>> GetAllExamsForStudentAsync(string studentId);
    }
}
