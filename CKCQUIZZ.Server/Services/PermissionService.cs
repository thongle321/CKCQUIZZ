using CKCQUIZZ.Server.Interfaces;
using CKCQUIZZ.Server.Models;
using CKCQUIZZ.Server.Viewmodels.Permission;
using Microsoft.AspNetCore.Identity;
using Microsoft.EntityFrameworkCore;

namespace CKCQUIZZ.Server.Services
{
    public class PermissionService(CkcquizzContext _context, RoleManager<ApplicationRole> _roleManager) : IPermissionService
    {

        public async Task<List<PermissionGroupListDTO>> GetAllAsync()
        {
            return await _roleManager.Roles
                .Where(r => r.TrangThai == true) 
                .Select(r => new PermissionGroupListDTO
                {
                    Id = r.Id,
                    TenNhomQuyen = r.Name!,
                    SoNguoiDung = _context.UserRoles.Count(ur => ur.RoleId == r.Id)
                }).ToListAsync();
        }

        public async Task<PermissionScreenDTO?> GetByIdAsync(string id)
        {
            var role = await _roleManager.Roles
                .Where(r => r.Id == id)
                .Select(r => new PermissionScreenDTO
                {
                    Id = r.Id,
                    TenNhomQuyen = r.Name!,
                    ThamGiaThi = r.ThamGiaThi,
                    ThamGiaHocPhan = r.ThamGiaHocPhan,

                    Permissions = r.ChiTietQuyens.Select(p => new PermissionDetailDTO
                    {
                        ChucNang = p.ChucNang,
                        HanhDong = p.HanhDong,
                        IsGranted = true 
                    }).ToList()
                })
                .FirstOrDefaultAsync();

            return role;
        }

        public async Task<IdentityResult> CreateAsync(PermissionScreenDTO dto)
        {
            var newRole = new ApplicationRole
            {
                Name = dto.TenNhomQuyen,
                TrangThai = true,
                ThamGiaThi = dto.ThamGiaThi,
                ThamGiaHocPhan = dto.ThamGiaHocPhan
            };

            await using var transaction = await _context.Database.BeginTransactionAsync();

            var result = await _roleManager.CreateAsync(newRole);
            if (!result.Succeeded)
            {
                await transaction.RollbackAsync();
                return result;
            }

            var permissionsToAdd = dto.Permissions
                .Where(p => p.IsGranted)
                .Select(p => new ChiTietQuyen
                {
                    RoleId = newRole.Id, 
                    ChucNang = p.ChucNang,
                    HanhDong = p.HanhDong
                });

            await _context.ChiTietQuyens.AddRangeAsync(permissionsToAdd);
            await _context.SaveChangesAsync();

            await transaction.CommitAsync();
            dto.Id = newRole.Id; 
            return IdentityResult.Success;
        }

        public async Task<IdentityResult> UpdateAsync(PermissionScreenDTO dto)
        {
            await using var transaction = await _context.Database.BeginTransactionAsync();

            try
            {
                var role = await _roleManager.Roles
                                             .Include(r => r.ChiTietQuyens)
                                             .FirstOrDefaultAsync(r => r.Id == dto.Id);

                if (role == null) return IdentityResult.Failed(new IdentityError { Description = "Không tìm thấy nhóm quyền." });

                role.Name = dto.TenNhomQuyen;
                role.ThamGiaThi = dto.ThamGiaThi;
                role.ThamGiaHocPhan = dto.ThamGiaHocPhan;

                _context.ChiTietQuyens.RemoveRange(role.ChiTietQuyens);

                var permissionsToAdd = dto.Permissions
                    .Where(p => p.IsGranted)
                    .Select(p => new ChiTietQuyen
                    {
                        RoleId = role.Id,
                        ChucNang = p.ChucNang,
                        HanhDong = p.HanhDong
                    });
                await _context.ChiTietQuyens.AddRangeAsync(permissionsToAdd);


                await _context.SaveChangesAsync();

                await transaction.CommitAsync();
                return IdentityResult.Success;
            }
            catch (Exception ex)
            {
                await transaction.RollbackAsync();
                return IdentityResult.Failed(new IdentityError { Description = "Đã xảy ra lỗi khi cập nhật." + ex.Message });
            }
        }

        public async Task<bool> DeleteAsync(string id)
        {
            var role = await _roleManager.FindByIdAsync(id);
            if (role == null) return false;

            role.TrangThai = false;
            var result = await _roleManager.UpdateAsync(role);

            return result.Succeeded;
        }

        public async Task<IEnumerable<DanhMucChucNang>> GetFunctionsAsync()
        {
            return await _context.DanhMucChucNangs.ToListAsync();
        }
    }
}