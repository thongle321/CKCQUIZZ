using CKCQUIZZ.Server.Interfaces;
using CKCQUIZZ.Server.Models;
using CKCQUIZZ.Server.Viewmodels;
using CKCQUIZZ.Server.Viewmodels.Subject;
using Microsoft.EntityFrameworkCore;

namespace CKCQUIZZ.Server.Services
{
    public class MonHocService(CkcquizzContext _context) : IMonHocService
    {


        public async Task<List<MonHoc>> GetAllAsync()
        {
            return await _context.MonHocs.ToListAsync();
        }

        public async Task<MonHoc?> GetByIdAsync(int id)
        {
            return await _context.MonHocs.FindAsync(id);
        }

        public async Task<MonHoc> CreateAsync(MonHoc monHocModel)
        {

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
            if(monHocModel is null)
            {
                return null;
            }
            _context.MonHocs.Remove(monHocModel);
            await _context.SaveChangesAsync();
            return monHocModel;
        }
    }

}

