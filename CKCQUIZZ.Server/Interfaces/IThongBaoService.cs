using CKCQUIZZ.Server.Models;
using CKCQUIZZ.Server.Viewmodels;
using CKCQUIZZ.Server.Viewmodels.ThongBao;

namespace CKCQUIZZ.Server.Interfaces
{
    public interface IThongBaoService 
    {
        Task<ThongBao?> GetByIdAsync(int id);
        Task<ThongBao> CreateAsync(ThongBao thongBao, List<int> lopId, string giangvienId);
        Task<List<ThongBaoGetAnnounceDTO>> GetThongBaoByLopIdAsync(int groupId);
        Task<PagedResult<ThongBaoGetAllDTO>> GetAllThongBaoNguoiDungAsync(string userId, int page, int pageSize, string? search = null);
        Task<ThongBao?> DeleteAsync(int matb);
        Task<ThongBaoDetailDTO?> GetChiTietThongBaoAsync(int matb);
        Task<ThongBao?> UpdateAsync(int matb, UpdateThongBaoRequestDTO thongBaoDTO, List<int> nhomIds);
        Task<List<ThongBaoDTO>> GetTinNhanChoNguoiDungAsync(string userId);
        Task<PagedResult<ThongBaoGetAllDTO>> GetAllThongBaoAsync(int page, int pageSize, string? search = null);
    }
}