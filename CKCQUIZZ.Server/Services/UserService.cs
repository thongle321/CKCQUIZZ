using CKCQUIZZ.Server.Interfaces;
using CKCQUIZZ.Server.Models;
using Microsoft.AspNetCore.Identity;
using System.Collections.Generic;

namespace CKCQUIZZ.Server.Services
{
    public class UserService(UserManager<NguoiDung> _userManager, RoleManager<IdentityRole> _roleManager) : IUserService
    {
        public async Task<List<NguoiDung>> GetAllAsync()
        {
            return _userManager.Users.ToList();
        }

        public async Task<NguoiDung?> GetByIdAsync(string id)
        {
            return await _userManager.FindByIdAsync(id);
        }

        public async Task<IdentityResult> CreateAsync(NguoiDung user, string password)
        {
            return await _userManager.CreateAsync(user, password);
        }

        public async Task<IdentityResult> AssignRoleAsync(NguoiDung user, string role)
        {
            if (!await _roleManager.RoleExistsAsync(role))
            {
                return IdentityResult.Failed(new IdentityError {
                    Description = $"Role '{role}' does not exist."
                });
            }
            
            return await _userManager.AddToRoleAsync(user, role);
        }

        public async Task<IdentityResult> UpdateAsync(NguoiDung user)
        {
            return await _userManager.UpdateAsync(user);
        }

        public async Task<IdentityResult> DeleteAsync(string id)
        {
            var user = await _userManager.FindByIdAsync(id);
            if (user == null)
            {
                return IdentityResult.Failed(new IdentityError { Description = $"Người dùng với ID {id} không tìm thấy" });
            }
            return await _userManager.DeleteAsync(user);
        }

        public async Task<List<string>> GetAllRolesAsync()
        {
            return _roleManager.Roles.Select(r => r.Name).ToList();
        }
    }
}