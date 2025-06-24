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
                .Include(l => l.GiangvienNavigation) // Include teacher information
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
            .ThenInclude(dsl => dsl.MamonhocNavigation)
            .Include(l => l.GiangvienNavigation) 
            .FirstOrDefaultAsync(l => l.Malop == id);

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
                .Include(l => l.GiangvienNavigation) // Include teacher information
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

            // Update teacher assignment if provided (only Admin should be able to change this)
            if (!string.IsNullOrEmpty(lopDTO.GiangvienId))
            {
                existingLop.Giangvien = lopDTO.GiangvienId;
            }

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
                .Where(ctl => ctl.Malop == lopId && ctl.Trangthai == true)
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

        public async Task<List<MonHocWithNhomLopDTO>> GetSubjectsAndGroupsForTeacherAsync(string teacherId, bool? hienthi)
        {
            var query = _context.Lops
                .Where(l => l.Giangvien == teacherId);

            if (hienthi.HasValue)
            {
                query = query.Where(l => l.Hienthi == hienthi.Value);
            }

            var lopsWithMonHoc = await query
                .Include(l => l.DanhSachLops)
                    .ThenInclude(dsl => dsl.MamonhocNavigation)
                .ToListAsync();

            var groupedData = lopsWithMonHoc
                .Where(l => l.DanhSachLops.Any()) 
                .GroupBy(l => new
                {
                    Mamonhoc = l.DanhSachLops.First().MamonhocNavigation.Mamonhoc,
                    Tenmonhoc = l.DanhSachLops.First().MamonhocNavigation.Tenmonhoc,
                    l.Namhoc,
                    l.Hocky
                })
                .Select(g => new MonHocWithNhomLopDTO
                {
                    Mamonhoc = g.Key.Mamonhoc,
                    Tenmonhoc = g.Key.Tenmonhoc,
                    Namhoc = g.Key.Namhoc,
                    Hocky = g.Key.Hocky,
                    NhomLop = g.Select(l => new NhomLopInMonHocDTO { Manhom = l.Malop, Tennhom = l.Tenlop }).ToList()
                })
                .OrderBy(m => m.Tenmonhoc) 
                .ToList();

            return groupedData;
        }

        // ===== JOIN REQUEST METHODS =====

        public async Task<ChiTietLop?> JoinClassByInviteCodeAsync(string inviteCode, string studentId)
        {
            // Find class by invite code
            var lop = await _context.Lops
                .FirstOrDefaultAsync(l => l.Mamoi == inviteCode && l.Trangthai == true && l.Hienthi == true);

            if (lop == null) return null;

            // Check if user exists
            var userExists = await _context.NguoiDungs.AnyAsync(u => u.Id == studentId);
            if (!userExists) return null;

            // Check if student is already in class (approved or pending)
            var alreadyInClass = await _context.ChiTietLops
                .AnyAsync(ctl => ctl.Malop == lop.Malop && ctl.Manguoidung == studentId);

            if (alreadyInClass) return null;

            // Create pending join request
            var chiTietLop = new ChiTietLop
            {
                Malop = lop.Malop,
                Manguoidung = studentId,
                Trangthai = false // Pending approval
            };

            await _context.ChiTietLops.AddAsync(chiTietLop);
            await _context.SaveChangesAsync();
            return chiTietLop;
        }

        public async Task<int> GetPendingRequestCountAsync(int lopId)
        {
            return await _context.ChiTietLops
                .CountAsync(ctl => ctl.Malop == lopId && ctl.Trangthai == false);
        }

        public async Task<List<PendingStudentDTO>> GetPendingStudentsAsync(int lopId)
        {
            var pendingStudents = await _context.ChiTietLops
                .Where(ctl => ctl.Malop == lopId && ctl.Trangthai == false)
                .Include(ctl => ctl.ManguoidungNavigation)
                .Select(ctl => new PendingStudentDTO
                {
                    Manguoidung = ctl.Manguoidung,
                    Hoten = ctl.ManguoidungNavigation.Hoten,
                    Email = ctl.ManguoidungNavigation.Email!,
                    Mssv = ctl.ManguoidungNavigation.Id,
                    NgayYeuCau = null // ChiTietLop doesn't have date field, could be added later
                })
                .ToListAsync();

            return pendingStudents;
        }

        public async Task<bool> ApproveJoinRequestAsync(int lopId, string studentId)
        {
            var chiTietLop = await _context.ChiTietLops
                .FirstOrDefaultAsync(ctl => ctl.Malop == lopId && ctl.Manguoidung == studentId && ctl.Trangthai == false);

            if (chiTietLop == null) return false;

            chiTietLop.Trangthai = true; // Approve the request
            await _context.SaveChangesAsync();
            return true;
        }

        public async Task<bool> RejectJoinRequestAsync(int lopId, string studentId)
        {
            var chiTietLop = await _context.ChiTietLops
                .FirstOrDefaultAsync(ctl => ctl.Malop == lopId && ctl.Manguoidung == studentId && ctl.Trangthai == false);

            if (chiTietLop == null) return false;

            _context.ChiTietLops.Remove(chiTietLop); // Remove the request
            await _context.SaveChangesAsync();
            return true;
        }
    
        public async Task<List<GetNguoiDungDTO>> GetTeachersInClassAsync(int lopId)
        {
            var teachers = await _context.Lops
                .Where(l => l.Malop == lopId)
                .Select(l => l.GiangvienNavigation)
                .Where(gv => gv != null)
                .Select(gv => new GetNguoiDungDTO
                {
                    MSSV = gv.Id,
                    Hoten = gv.Hoten,
                    Email = gv.Email!,
                    Ngaysinh = gv.Ngaysinh,
                    PhoneNumber = gv.PhoneNumber!,
                    Gioitinh = gv.Gioitinh,
                    Trangthai = gv.Trangthai,
                })
                .ToListAsync();
    
            return teachers!;
        }
    }

}
