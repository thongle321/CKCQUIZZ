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
    }
}
