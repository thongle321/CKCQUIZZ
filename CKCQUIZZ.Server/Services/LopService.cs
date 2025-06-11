using CKCQUIZZ.Server.Interfaces;
using CKCQUIZZ.Server.Models;
using CKCQUIZZ.Server.Viewmodels.Lop;
using Microsoft.EntityFrameworkCore;

namespace CKCQUIZZ.Server.Services
{
    public class LopService(CkcquizzContext _context) : ILopService
    {

        public async Task<List<Lop>> GetAllAsync(string giangvienId, bool? hienthi)
        {
            var query = _context.Lops
                .Where(l => l.Giangvien == giangvienId)
                .Include(l => l.ChiTietLops)
                .Include(l => l.DanhSachLops)
                    .ThenInclude(dsl => dsl.MamonhocNavigation)
                .AsQueryable();

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

            // Add the single subject to DanhSachLop
            await _context.DanhSachLops.AddAsync(new DanhSachLop { Malop = lopModel.Malop, Mamonhoc = mamonhoc });
            await _context.SaveChangesAsync(); // Save changes for DanhSachLop

            var createdLop = await _context.Lops
                .Include(l => l.ChiTietLops) // Để tính Siso
                .Include(l => l.DanhSachLops)
                    .ThenInclude(dsl => dsl.MamonhocNavigation) // Để lấy Tenmonhoc
                .FirstOrDefaultAsync(l => l.Malop == lopModel.Malop);
            return createdLop ?? throw new Exception("Không thể tìm thấy lớp vừa được tạo.");
        }

        public async Task<Lop?> UpdateAsync(int id, UpdateLopRequestDTO lopDTO)
        {
            var existingLop = await _context.Lops
                .Include(l => l.DanhSachLops) // Include DanhSachLops to update it
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

            // Remove existing subject associations
            _context.DanhSachLops.RemoveRange(existingLop.DanhSachLops);

            // Add the new single subject association
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
        public async Task<Lop?> ToggleStatusAsync(int id, bool status)
        {
            var lop = await _context.Lops.FindAsync(id);
            if (lop == null) return null;

            lop.Hienthi = status;
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

        public async Task<IEnumerable<NguoiDung>> GetStudentsInClassAsync(int lopId)
        {
            return await _context.ChiTietLops
                .Where(ctl => ctl.Malop == lopId)
                .Select(ctl => ctl.ManguoidungNavigation) // Chỉ lấy thông tin người dùng
                .ToListAsync();
        }
        public async Task<ChiTietLop?> AddStudentToClassAsync(int lopId, string manguoidungId)
        {
            // Kiểm tra lớp và người dùng có tồn tại không
            var lopExists = await _context.Lops.AnyAsync(l => l.Malop == lopId);
            var userExists = await _context.NguoiDungs.AnyAsync(u => u.Id == manguoidungId);

            if (!lopExists || !userExists) return null;

            // Kiểm tra sinh viên đã có trong lớp chưa
            var alreadyInClass = await _context.ChiTietLops
                .AnyAsync(ctl => ctl.Malop == lopId && ctl.Manguoidung == manguoidungId);

            if (alreadyInClass) return null;

            var chiTietLop = new ChiTietLop
            {
                Malop = lopId,
                Manguoidung = manguoidungId,
                Trangthai = true // Mặc định là đang hoạt động
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
