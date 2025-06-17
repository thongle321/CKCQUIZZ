using CKCQUIZZ.Server.Interfaces;
using CKCQUIZZ.Server.Models;
using CKCQUIZZ.Server.Viewmodels;
using CKCQUIZZ.Server.Viewmodels.Lop;
using CKCQUIZZ.Server.Viewmodels.NguoiDung;
using Microsoft.EntityFrameworkCore;

namespace CKCQUIZZ.Server.Services
{
    public class LopService(CkcquizzContext _context) : ILopService
    {

        public async Task<List<Lop>> GetAllAsync(string userId, bool? hienthi, string userRole)
        {
            var query = _context.Lops
                .Include(l => l.ChiTietLops)
                .Include(l => l.DanhSachLops)
                    .ThenInclude(dsl => dsl.MamonhocNavigation)
                .AsQueryable();

            // Lọc theo role
            switch (userRole?.ToLower())
            {
                case "admin":
                    // Admin xem tất cả lớp - không filter
                    break;

                case "teacher":
                    // Teacher chỉ xem lớp của mình
                    query = query.Where(l => l.Giangvien == userId);
                    break;

                case "student":
                    // Student chỉ xem lớp đã tham gia
                    query = query.Where(l => l.ChiTietLops.Any(ctl => ctl.Manguoidung == userId && ctl.Trangthai == true));
                    break;

                default:
                    // Role không xác định - trả về rỗng
                    return new List<Lop>();
            }

            if (hienthi.HasValue)
            {
                query = query.Where(l => l.Hienthi == hienthi.Value);
            }

            return await query.ToListAsync();
        }

        public async Task<Lop?> GetByIdAsync(int id)
        {
            return await _context.Lops
            .Include(l => l.ChiTietLops)
            .Include(l => l.DanhSachLops)
            .ThenInclude(dsl => dsl.MamonhocNavigation).FirstOrDefaultAsync(l => l.Malop == id);

        }

        public async Task<Lop> CreateAsync(Lop lopModel, int mamonhoc, string giangvienId)
        {
            lopModel.Giangvien = giangvienId;
            lopModel.Mamoi = Guid.NewGuid().ToString().ToUpper().Substring(0, 6);

            await _context.Lops.AddAsync(lopModel);
            await _context.SaveChangesAsync();

            await _context.DanhSachLops.AddAsync(new DanhSachLop { Malop = lopModel.Malop, Mamonhoc = mamonhoc });
            await _context.SaveChangesAsync();

            var createdLop = await _context.Lops
                .Include(l => l.ChiTietLops)
                .Include(l => l.DanhSachLops)
                    .ThenInclude(dsl => dsl.MamonhocNavigation)
                .FirstOrDefaultAsync(l => l.Malop == lopModel.Malop);
            return createdLop ?? throw new Exception("Không thể tìm thấy lớp vừa được tạo.");
        }

        public async Task<Lop?> UpdateAsync(int id, UpdateLopRequestDTO lopDTO)
        {
            var existingLop = await _context.Lops
                .Include(l => l.DanhSachLops)
                .FirstOrDefaultAsync(x => x.Malop == id);

            if (existingLop is null)
            {
                return null;
            }

            existingLop.Tenlop = lopDTO.Tenlop;
            existingLop.Ghichu = lopDTO.Ghichu;
            existingLop.Namhoc = lopDTO.Namhoc;
            existingLop.Hocky = lopDTO.Hocky;
            existingLop.Trangthai = lopDTO.Trangthai;
            existingLop.Hienthi = lopDTO.Hienthi;

            _context.DanhSachLops.RemoveRange(existingLop.DanhSachLops);

            existingLop.DanhSachLops.Add(new DanhSachLop { Malop = id, Mamonhoc = lopDTO.Mamonhoc });

            await _context.SaveChangesAsync();

            return existingLop;
        }

        public async Task<Lop?> DeleteAsync(int id)
        {
            var lopModel = await _context.Lops.FirstOrDefaultAsync(x => x.Malop == id);
            if (lopModel is null)
            {
                return null;
            }
            var chiTietLopModel = _context.ChiTietLops.Where(x => x.Malop == id);
            _context.ChiTietLops.RemoveRange(chiTietLopModel);
            var danhSachLopModel = _context.DanhSachLops.Where(x => x.Malop == id);
            _context.DanhSachLops.RemoveRange(danhSachLopModel);

            _context.Lops.Remove(lopModel);

            await _context.SaveChangesAsync();
            return lopModel;
        }
        public async Task<Lop?> ToggleStatusAsync(int id, bool hienthi)
        {
            var lop = await _context.Lops.FindAsync(id);
            if (lop == null) return null;

            lop.Hienthi = hienthi;
            await _context.SaveChangesAsync();
            return lop;
        }

        public async Task<string?> RefreshInviteCodeAsync(int id)
        {
            var lop = await _context.Lops.FindAsync(id);
            if (lop == null) return null;

            var newCode = Guid.NewGuid().ToString().ToUpper().Substring(0, 6);
            lop.Mamoi = newCode;
            await _context.SaveChangesAsync();
            return newCode;
        }

        public async Task<PagedResult<GetNguoiDungDTO>> GetStudentsInClassAsync(int lopId, int pageNumber, int pageSize, string? searchQuery)
        {
            var query = _context.ChiTietLops
                .Where(ctl => ctl.Malop == lopId)
                .Select(ctl => ctl.ManguoidungNavigation);

            if (!string.IsNullOrWhiteSpace(searchQuery))
            {
                var lowerCaseSearchQuery = searchQuery.Trim().ToLower();
                query = query.Where(sv =>
                    sv.Hoten.ToLower().Contains(lowerCaseSearchQuery) ||
                    sv.UserName!.ToLower().Contains(lowerCaseSearchQuery) ||
                    sv.Email!.ToLower().Contains(lowerCaseSearchQuery) ||
                    sv.Id.ToLower().Contains(lowerCaseSearchQuery));
            }

            var totalCount = await query.CountAsync();

            var fromDb = await query.Skip((pageNumber - 1) * pageSize)
                                   .Take(pageSize)
                                   .ToListAsync();

            var students = fromDb.Select(student => new GetNguoiDungDTO
            {
                MSSV = student.Id,
                Hoten = student.Hoten,
                Email = student.Email!,
                Ngaysinh = student.Ngaysinh,
                PhoneNumber = student.PhoneNumber!,
                Gioitinh = student.Gioitinh,
                Trangthai = student.Trangthai,
            }).ToList();

            return new PagedResult<GetNguoiDungDTO>
            {
                TotalCount = totalCount,
                Items = students
            };

        }
        public async Task<ChiTietLop?> AddStudentToClassAsync(int lopId, string manguoidungId)
        {
            var lopExists = await _context.Lops.AnyAsync(l => l.Malop == lopId);
            var userExists = await _context.NguoiDungs.AnyAsync(u => u.Id == manguoidungId);

            if (!lopExists || !userExists) return null;

            var alreadyInClass = await _context.ChiTietLops
                .AnyAsync(ctl => ctl.Malop == lopId && ctl.Manguoidung == manguoidungId);

            if (alreadyInClass) return null;

            var chiTietLop = new ChiTietLop
            {
                Malop = lopId,
                Manguoidung = manguoidungId,
                Trangthai = true
            };

            await _context.ChiTietLops.AddAsync(chiTietLop);
            await _context.SaveChangesAsync();
            return chiTietLop;
        }

        public async Task<bool> KickStudentFromClassAsync(int lopId, string manguoidungId)
        {
            var chiTietLop = await _context.ChiTietLops
                .FirstOrDefaultAsync(ctl => ctl.Malop == lopId && ctl.Manguoidung == manguoidungId);

            if (chiTietLop == null) return false;

            _context.ChiTietLops.Remove(chiTietLop);
            await _context.SaveChangesAsync();
            return true;
        }

    }

}
