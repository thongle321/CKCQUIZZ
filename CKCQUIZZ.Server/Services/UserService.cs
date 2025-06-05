using CKCQUIZZ.Server.Interfaces;
using CKCQUIZZ.Server.Models;
using CKCQUIZZ.Server.Viewmodels.User;
using Microsoft.AspNetCore.Identity;
using Microsoft.EntityFrameworkCore;
using System.Collections.Generic;

namespace CKCQUIZZ.Server.Services
{
    public class UserService(UserManager<NguoiDung> _userManager, RoleManager<IdentityRole> _roleManager) : IUserService
    {

        public async Task<PagedResult<GetUserInfoDTO>> GetAllAsync(int pageNumber, int pageSize)
        {
            var usersFromDb = await _userManager.Users
                                                .Skip((pageNumber - 1) * pageSize)
                                                .Take(pageSize)
                                                .ToListAsync();
            var totalUsers = await _userManager.Users.CountAsync();
            var usersToReturn = new List<GetUserInfoDTO>();
            foreach (var user in usersFromDb)
            {
                var rolesForUser = await _userManager.GetRolesAsync(user);
                usersToReturn.Add(new GetUserInfoDTO
                {
                    MSSV = user.Id,
                    UserName = user.UserName!,
                    FullName = user.Hoten,
                    Email = user.Email!,
                    Dob = user.Ngaysinh,
                    PhoneNumber = user.PhoneNumber!,
                    Status = user.Trangthai,
                    CurrentRole = rolesForUser.FirstOrDefault()
                });
            }
            return new PagedResult<GetUserInfoDTO>
            {
                TotalCount = totalUsers,
                Items = usersToReturn
            };
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
                return IdentityResult.Failed(new IdentityError
                {
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
            return await _roleManager.Roles.Select(r => r.Name!).ToListAsync();
        }
        public async Task<IdentityResult> SetUserRoleAsync(NguoiDung user, string newRoleName)
        {
            var currentRoles = await _userManager.GetRolesAsync(user);
            if (currentRoles.Any())
            {
                var removeResult = await _userManager.RemoveFromRolesAsync(user, currentRoles);
                if (!removeResult.Succeeded) return removeResult;
            }

            if (!string.IsNullOrEmpty(newRoleName))
            {
                var addResult = await _userManager.AddToRoleAsync(user, newRoleName);
                if (!addResult.Succeeded) return addResult;
            }
            return IdentityResult.Success;
        }

    }
}