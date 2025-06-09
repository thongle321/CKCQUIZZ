using CKCQUIZZ.Server.Viewmodels.Lop;

namespace CKCQUIZZ.Server.Interfaces
{
    public interface ILopService
    {
        Task<List<LopDTO>> GetAllAsync();
        Task<LopDTO?> GetByIdAsync(int id);
        Task<LopDTO> CreateAsync(LopDTO dto);
        Task<bool> UpdateAsync(int id, LopDTO dto);
        Task<bool> DeleteAsync(int id);
    }

}

