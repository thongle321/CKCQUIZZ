using CKCQUIZZ.Server.Viewmodels.CauHoi;
namespace CKCQUIZZ.Server.Interfaces
{
    public interface ICauHoiService
    {
        Task<PagedResult<CauHoiDto>> GetAllPagingAsync(QueryCauHoiDto query);
<<<<<<< HEAD
        Task<CauHoiDetailDto> GetByIdAsync(int id);
        Task<List<CauHoiDetailDto>> GetByMaMonHocAsync(int maMonHoc, string userId);
=======
        Task<CauHoiDetailDto?> GetByIdAsync(int id);
        Task<List<CauHoiDetailDto>> GetByMaMonHocAsync(int maMonHoc);
>>>>>>> b6807776675e9b68fa2a543e6c838f52a42f6b83
        Task<int> CreateAsync(CreateCauHoiRequestDto request, string userId);
        Task<bool> UpdateAsync(int id, UpdateCauHoiRequestDto request);
        Task<bool> DeleteAsync(int id);
        Task<PagedResult<CauHoiDto>> GetQuestionsForAssignedSubjectsAsync(string userId, QueryCauHoiDto query);

    }
}