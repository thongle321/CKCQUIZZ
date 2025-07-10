using CKCQUIZZ.Server.Interfaces;
using CKCQUIZZ.Server.Models;
using CKCQUIZZ.Server.Viewmodels;
using CKCQUIZZ.Server.Viewmodels.NguoiDung;
using Microsoft.AspNetCore.Identity;
using Microsoft.EntityFrameworkCore;
using System.Collections.Generic;

namespace CKCQUIZZ.Server.Services
{
    public class NguoiDungService(UserManager<NguoiDung> _userManager, RoleManager<ApplicationRole> _roleManager) : INguoiDungService
    {

        public async Task<PagedResult<GetNguoiDungDTO>> GetAllAsync(int pageNumber, int pageSize, string? searchQuery, string? role = null)
        {
            var query = _userManager.Users.
            Where(x => x.Hienthi == true).
            AsQueryable();

            if (!string.IsNullOrWhiteSpace(searchQuery))
            {
                var lowerCaseSearchQuery = searchQuery.Trim().ToLower();
                query = query.Where(x => x.Email!.Contains(lowerCaseSearchQuery, StringComparison.CurrentCultureIgnoreCase) ||
                x.Hoten.Contains(lowerCaseSearchQuery, StringComparison.CurrentCultureIgnoreCase) ||
                x.Id.Contains(lowerCaseSearchQuery, StringComparison.CurrentCultureIgnoreCase));
            }

            var totalUsers = await query.CountAsync();
            var usersFromDb = await query.Skip((pageNumber - 1) * pageSize)
                                                .Take(pageSize)
                                                .ToListAsync();
            var usersToReturn = new List<GetNguoiDungDTO>();

            foreach (var user in usersFromDb)
            {
                var rolesForUser = await _userManager.GetRolesAsync(user);
                var userDto = new GetNguoiDungDTO
                {
                    MSSV = user.Id,
                    Hoten = user.Hoten,
                    Email = user.Email!,
                    Ngaysinh = user.Ngaysinh,
                    PhoneNumber = user.PhoneNumber!,
                    Gioitinh = user.Gioitinh,
                    Trangthai = user.Trangthai,
                    CurrentRole = rolesForUser.FirstOrDefault(),
                    Hienthi = user.Hienthi
                };

                if (string.IsNullOrWhiteSpace(role) || rolesForUser.Contains(role))
                {
                    usersToReturn.Add(userDto);
                }
            }

            return new PagedResult<GetNguoiDungDTO>
            {
                TotalCount = usersToReturn.Count,
                Items = usersToReturn,
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

        public async Task<IdentityResult> SoftDeleteAsync(string id, bool hienthi)
        {
            var user = await _userManager.FindByIdAsync(id);
            if (user == null)
            {
                return IdentityResult.Failed(new IdentityError { Description = $"Người dùng với ID {id} không tìm thấy" });
            }

            user.Hienthi = hienthi;
            return await _userManager.UpdateAsync(user);
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