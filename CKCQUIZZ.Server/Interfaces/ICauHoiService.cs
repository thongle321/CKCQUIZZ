﻿using CKCQUIZZ.Server.Viewmodels.CauHoi;
namespace CKCQUIZZ.Server.Interfaces
{
    public interface ICauHoiService
    {
        Task<PagedResult<CauHoiDto>> GetAllPagingAsync(QueryCauHoiDto query);
        Task<CauHoiDetailDto?> GetByIdAsync(int id);
        Task<List<CauHoiDetailDto>> GetByMaMonHocAsync(int maMonHoc);
        Task<int> CreateAsync(CreateCauHoiRequestDto request, string userId);
        Task UpdateAsync(int id, UpdateCauHoiRequestDto request, string userId);
        Task<bool> DeleteAsync(int id);
        Task<PagedResult<CauHoiDto>> GetQuestionsForAssignedSubjectsAsync(string userId, QueryCauHoiDto query);
        Task<PagedResult<CauHoiDto>> GetMyCreatedQuestionsAsync(string userId, QueryCauHoiDto query);
        Task<(bool Success, string Message)> HardDeleteAsync(int id, string userId);
    }
}