using CKCQUIZZ.Server.Interfaces;
using CKCQUIZZ.Server.Models;
using CKCQUIZZ.Server.Viewmodels;
using CKCQUIZZ.Server.Viewmodels.MonHoc;
using Microsoft.EntityFrameworkCore;

namespace CKCQUIZZ.Server.Services
{
    public class MonHocService(CkcquizzContext _context) : IMonHocService
    {



        public async Task<List<MonHoc>> GetAllAsync()
        {
            return await _context.MonHocs
            .Where(mh => mh.Trangthai == true)
            .ToListAsync();
        }

        public async Task<MonHoc?> GetByIdAsync(int id)
        {
            return await _context.MonHocs
            .Where(mh => mh.Trangthai == true)
            .FirstOrDefaultAsync(x => x.Mamonhoc == id);
        }

        public async Task<MonHoc> CreateAsync(MonHoc monHocModel)
        {
            var existingMonHoc = await _context.MonHocs
            .AnyAsync(mh => mh.Mamonhoc == monHocModel.Mamonhoc);
            if (existingMonHoc)
            {
                throw new InvalidOperationException($"Mã môn học '{monHocModel.Mamonhoc}' đã tồn tại.");
            }
            await _context.MonHocs.AddAsync(monHocModel);
            await _context.SaveChangesAsync();
            return monHocModel;
        }

        public async Task<MonHoc?> UpdateAsync(int id, UpdateMonHocRequestDTO monHocDTO)
        {
            var existingMonHoc = await _context.MonHocs.FirstOrDefaultAsync(x => x.Mamonhoc == id);
            if(existingMonHoc is null)
            {
                return null;
            }
            existingMonHoc.Tenmonhoc = monHocDTO.Tenmonhoc;
            existingMonHoc.Sotinchi = monHocDTO.Sotinchi;
            existingMonHoc.Sotietlythuyet = monHocDTO.Sotietlythuyet;
            existingMonHoc.Sotietthuchanh = monHocDTO.Sotietthuchanh;
            existingMonHoc.Trangthai = monHocDTO.Trangthai;
            await _context.SaveChangesAsync();

            return existingMonHoc;
        }

        public async Task<MonHoc?> DeleteAsync(int id)
        {
            var monHocModel = await _context.MonHocs.FirstOrDefaultAsync(x => x.Mamonhoc == id);
            if (monHocModel is null)
            {
                return null;
            }
            var hasResults = await _context.DanhSachLops
                .AnyAsync(l => l.Mamonhoc == id && l.MalopNavigation.Trangthai == true);
                
            if (hasResults)
            {
                throw new InvalidOperationException("Không thể xóa môn học vì lớp đang hoạt động  .");
            }
            monHocModel.Trangthai = false;
            _context.Entry(monHocModel).State = EntityState.Modified;
            var result = await _context.SaveChangesAsync();
            return result > 0 ? monHocModel : null;
        }
    }

}

