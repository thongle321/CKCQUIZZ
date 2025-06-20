﻿using CKCQUIZZ.Server.Viewmodels.CauHoi;
namespace CKCQUIZZ.Server.Interfaces
{
    public interface ICauHoiService
    {
        Task<PagedResult<CauHoiDto>> GetAllPagingAsync(QueryCauHoiDto query);
        Task<CauHoiDetailDto> GetByIdAsync(int id);
        Task<int> CreateAsync(CreateCauHoiRequestDto request, string userId);
        Task<bool> UpdateAsync(int id, UpdateCauHoiRequestDto request);
        Task<bool> DeleteAsync(int id);

    }
}