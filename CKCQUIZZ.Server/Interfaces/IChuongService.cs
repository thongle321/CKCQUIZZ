using CKCQUIZZ.Server.Viewmodels.Chuong;
namespace CKCQUIZZ.Server.Interfaces
{
    public interface IChuongService
    {
        Task<List<ChuongDTO>> GetAllAsync(int? mamonhocId, string userId);
        Task<ChuongDTO?> GetByIdAsync(int id, string userId);
        Task<ChuongDTO> CreateAsync(CreateChuongRequestDTO createDto, string userId);
        Task<ChuongDTO?> UpdateAsync(int id, UpdateChuongResquestDTO updateDto, string userId);
        Task<bool> DeleteAsync(int id, string userId);
    }
}