using CKCQUIZZ.Server.Viewmodels.Chuong;
namespace CKCQUIZZ.Server.Services.Interfaces
{
    public interface IChuongService
    {
        Task<List<ChuongDTO>> GetAllAsync(int? mamonhocId);
        Task<ChuongDTO?> GetByIdAsync(int id);
        Task<ChuongDTO> CreateAsync(CreateChuongRequestDTO createDto);
        Task<ChuongDTO?> UpdateAsync(int id, UpdateChuongResquestDTO updateDto);
        Task<bool> DeleteAsync(int id);
    }
}