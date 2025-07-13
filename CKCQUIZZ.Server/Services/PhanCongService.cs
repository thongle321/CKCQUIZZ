using CKCQUIZZ.Server.Interfaces;
using CKCQUIZZ.Server.Models;
using CKCQUIZZ.Server.Viewmodels.PhanCong;
using CKCQUIZZ.Server.Viewmodels.MonHoc;
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

        public async Task<List<int>> AddAssignmentAsync(string giangvienId, List<int> listMaMonHoc)
        {
            var existingAssignments = await _context.PhanCongs
                .Where(pc => pc.Manguoidung == giangvienId && listMaMonHoc.Contains(pc.Mamonhoc))
                .Select(pc => pc.Mamonhoc)
                .ToListAsync();

            var newAssignmentsToAdd = listMaMonHoc
                .Where(subjectId => !existingAssignments.Contains(subjectId))
                .Select(subjectId => new PhanCong
                {
                    Mamonhoc = subjectId,
                    Manguoidung = giangvienId
                })
                .ToList();

            if (!newAssignmentsToAdd.Any())
            {
                return new List<int>();
            }

            await _context.PhanCongs.AddRangeAsync(newAssignmentsToAdd);
            await _context.SaveChangesAsync();

            return newAssignmentsToAdd.Select(a => a.Mamonhoc).ToList();
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
                .Where(x=>x.MamonhocNavigation.Trangthai==true)
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

        public async Task<List<MonHocDTO>> GetAssignedSubjectsAsync(string userId)
        {
            var assignedSubjects = await _context.PhanCongs
                .Where(pc => pc.Manguoidung == userId)
                .Include(pc => pc.MamonhocNavigation)
                .Select(pc => new MonHocDTO
                {
                    Mamonhoc = pc.MamonhocNavigation.Mamonhoc,
                    Tenmonhoc = pc.MamonhocNavigation.Tenmonhoc,
                    Sotinchi = pc.MamonhocNavigation.Sotinchi,
                    Sotietlythuyet = pc.MamonhocNavigation.Sotietlythuyet,
                    Sotietthuchanh = pc.MamonhocNavigation.Sotietthuchanh,
                    Trangthai = pc.MamonhocNavigation.Trangthai
                })
                .ToListAsync();

            return assignedSubjects;
        }
    }
}