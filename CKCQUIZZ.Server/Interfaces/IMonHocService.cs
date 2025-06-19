using CKCQUIZZ.Server.Models;
using CKCQUIZZ.Server.Viewmodels;
using CKCQUIZZ.Server.Viewmodels.MonHoc;

namespace CKCQUIZZ.Server.Interfaces
{
    public interface IMonHocService
    {
        Task<List<MonHoc>> GetAllAsync();
        Task<MonHoc?> GetByIdAsync(int id);
        Task<MonHoc> CreateAsync(MonHoc monHocModel);
        Task<MonHoc?> UpdateAsync(int id, UpdateMonHocRequestDTO monHocDTO);
        Task<MonHoc?> DeleteAsync(int id);

    }

}

