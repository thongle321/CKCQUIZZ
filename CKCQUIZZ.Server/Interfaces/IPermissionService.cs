using CKCQUIZZ.Server.Models;
using CKCQUIZZ.Server.Viewmodels.Permission;
using CKCQUIZZ.Server.Viewmodels.Role;
using Microsoft.AspNetCore.Identity;

namespace CKCQUIZZ.Server.Interfaces
{
    public interface IPermissionService
    {
        Task<List<PermissionGroupListDTO>> GetAllAsync();
        Task<PermissionScreenDTO?> GetByIdAsync(string id);
        Task<IdentityResult> CreateAsync(PermissionScreenDTO dto);
        Task<IdentityResult> UpdateAsync(PermissionScreenDTO dto);
        Task<bool> DeleteAsync(string id);
        Task<IEnumerable<DanhMucChucNang>> GetFunctionsAsync();
        Task<List<string>> GetUserPermissionsAsync(string userId);
    }
}