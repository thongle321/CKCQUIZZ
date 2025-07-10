using CKCQUIZZ.Server.Models;
using CKCQUIZZ.Server.Viewmodels;
using System.Collections.Generic;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Identity;
using CKCQUIZZ.Server.Viewmodels.NguoiDung;

namespace CKCQUIZZ.Server.Interfaces
{
    public interface INguoiDungService
    {
        Task<PagedResult<GetNguoiDungDTO>> GetAllAsync(int pageNumber, int pageSize, string? searchQuery, string? role = null);
        Task<NguoiDung?> GetByIdAsync(string id);
        Task<IdentityResult> CreateAsync(NguoiDung user, string password);
        Task<IdentityResult> AssignRoleAsync(NguoiDung user, string role);
        Task<IdentityResult> UpdateAsync(NguoiDung user);
        Task<IdentityResult> DeleteAsync(string id);
        Task<List<string>> GetAllRolesAsync();
        Task<IdentityResult> SoftDeleteAsync(string id, bool status);
        Task<IdentityResult> SetUserRoleAsync(NguoiDung user, string newRoleName);
    }
}