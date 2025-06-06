using CKCQUIZZ.Server.Models;
using CKCQUIZZ.Server.Viewmodels;
using System.Collections.Generic;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Identity;
using CKCQUIZZ.Server.Viewmodels.User;

namespace CKCQUIZZ.Server.Interfaces
{
    public interface IUserService
    {
        Task<PagedResult<GetUserInfoDTO>> GetAllAsync(int pageNumber, int pageSize, string? searchQuery);
        Task<NguoiDung?> GetByIdAsync(string id);
        Task<IdentityResult> CreateAsync(NguoiDung user, string password);
        Task<IdentityResult> AssignRoleAsync(NguoiDung user, string role);
        Task<IdentityResult> UpdateAsync(NguoiDung user);
        Task<IdentityResult> DeleteAsync(string id);
        Task<List<string>> GetAllRolesAsync();
        Task<IdentityResult> SetUserRoleAsync(NguoiDung user, string newRoleName);
    }
}