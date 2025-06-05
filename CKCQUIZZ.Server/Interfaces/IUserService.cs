using CKCQUIZZ.Server.Models;
using System.Collections.Generic;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Identity;

namespace CKCQUIZZ.Server.Interfaces
{
    public interface IUserService
    {
        Task<List<NguoiDung>> GetAllAsync();
        Task<NguoiDung?> GetByIdAsync(string id);
        Task<IdentityResult> CreateAsync(NguoiDung user, string password);
        Task<IdentityResult> AssignRoleAsync(NguoiDung user, string role);
        Task<IdentityResult> UpdateAsync(NguoiDung user);
        Task<IdentityResult> DeleteAsync(string id);
        Task<List<string>> GetAllRolesAsync();
    }
}