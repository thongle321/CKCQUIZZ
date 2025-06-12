using CKCQUIZZ.Server.Interfaces;
using CKCQUIZZ.Server.Models;
using CKCQUIZZ.Server.Viewmodels.PhanCong;
using CKCQUIZZ.Server.Viewmodels.Subject;
using Microsoft.AspNetCore.Identity;
using Microsoft.EntityFrameworkCore;

namespace CKCQUIZZ.Server.Services
{
    public class PhanCongService(CkcquizzContext _context) : IPhanCongService
    {
        public async Task<List<PhanCongDTO>> GetAllAsync()
        {
            var query = _context.PhanCongs
                .Include(x => x.ManguoidungNavigation)
                .Include(x => x.MamonhocNavigation)
                .AsQueryable();

            return await query.Select(x => new PhanCongDTO
            {
                Mamonhoc = x.Mamonhoc,
                Manguoidung = x.Manguoidung,
                Hoten = x.ManguoidungNavigation.Hoten,
                Tenmonhoc = x.MamonhocNavigation.Tenmonhoc
            }).ToListAsync();
        }

        public async Task<List<GetGiangVienDTO>> GetGiangVienAsync()
        {
            var giangVien = await _context.Users
                .Join(_context.UserRoles,
                    user => user.Id,
                    userRole => userRole.UserId,
                    (user, userRole) => new { user, userRole })
                .Join(_context.Roles,
                    userRole => userRole.userRole.RoleId,
                    role => role.Id,
                    (userRole, role) => new { userRole.user, role })
                .Where(ur => ur.role.Name == "Teacher" && ur.role.ChiTietQuyens.Any(ctq =>
                    ctq.ChucNang == "cauhoi" ||
                    ctq.ChucNang == "monhoc" ||
                    ctq.ChucNang == "hocphan" ||
                    ctq.ChucNang == "chuong"))
                .Select(ur => new GetGiangVienDTO
                {
                    Id = ur.user.Id,
                    Hoten = ur.user.Hoten,
                    Manhomquyen = ur.role.Name
                })
                .Distinct()
                .ToListAsync();
            return giangVien;
        }

        public async Task<bool> AddAssignmentAsync(string giangvienId, List<int> listMaMonHoc)
        {
            var assignments = listMaMonHoc.Select(subjectId => new PhanCong
            {
                Mamonhoc = subjectId,
                Manguoidung = giangvienId
            }).ToList();

            await _context.PhanCongs.AddRangeAsync(assignments);
            var result = await _context.SaveChangesAsync();
            return result > 0;
        }

        public async Task<bool> DeleteAssignmentAsync(int maMonHoc, string maNguoiDung)
        {
            var assignment = await _context.PhanCongs
                .FirstOrDefaultAsync(pc => pc.Mamonhoc == maMonHoc && pc.Manguoidung == maNguoiDung);

            if (assignment == null)
            {
                return false;
            }

            _context.PhanCongs.Remove(assignment);
            var result = await _context.SaveChangesAsync();
            return result > 0;
        }

        public async Task<bool> DeleteAllAssignmentsByUserAsync(string maNguoiDung)
        {
            var assignmentsToDelete = await _context.PhanCongs
                .Where(pc => pc.Manguoidung == maNguoiDung)
                .ToListAsync();

            if (!assignmentsToDelete.Any())
            {
                return false;
            }

            _context.PhanCongs.RemoveRange(assignmentsToDelete);
            var result = await _context.SaveChangesAsync();
            return result > 0;
        }

        public async Task<List<PhanCongDTO>> GetAssignmentByUserAsync(string maNguoiDung)
        {
            var assignments = await _context.PhanCongs
                .Where(pc => pc.Manguoidung == maNguoiDung)
                .Include(x => x.ManguoidungNavigation)
                .Include(x => x.MamonhocNavigation)
                .Select(x => new PhanCongDTO
                {
                    Mamonhoc = x.Mamonhoc,
                    Manguoidung = x.Manguoidung,
                    Hoten = x.ManguoidungNavigation.Hoten,
                    Tenmonhoc = x.MamonhocNavigation.Tenmonhoc
                })
                .ToListAsync();

            return assignments;
        }
    }
}