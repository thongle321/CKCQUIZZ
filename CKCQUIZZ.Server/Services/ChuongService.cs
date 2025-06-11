using CKCQUIZZ.Server.Mappers;
using CKCQUIZZ.Server.Models;
using CKCQUIZZ.Server.Interfaces;
using CKCQUIZZ.Server.Viewmodels;
using CKCQUIZZ.Server.Viewmodels.Chuong;
using Microsoft.EntityFrameworkCore;
using CKCQUIZZ.Server.Services.Interfaces;
namespace CKCQUIZZ.Server.Services
{
    public class ChuongService : IChuongService
    {
        private readonly CkcquizzContext _context;

        public ChuongService(CkcquizzContext context)
        {
            _context = context;
        }

        public async Task<List<ChuongDTO>> GetAllAsync(int? mamonhocId)
        {
            var query = _context.Chuongs.AsQueryable();

            if (mamonhocId.HasValue && mamonhocId.Value > 0)
            {
                query = query.Where(c => c.Mamonhoc == mamonhocId.Value);
            }

            var result = await query
                .Select(c => c.ToChuongDto())
                .ToListAsync();

            return result;
        }

        public async Task<ChuongDTO?> GetByIdAsync(int id)
        {
            var chuong = await _context.Chuongs.FindAsync(id);
            return chuong?.ToChuongDto();
        }

        public async Task<ChuongDTO> CreateAsync(CreateChuongRequestDTO createDto)
        {
            var chuongModel = createDto.ToChuongFromCreateDto();
            await _context.Chuongs.AddAsync(chuongModel);
            await _context.SaveChangesAsync();
            return chuongModel.ToChuongDto();
        }

        public async Task<ChuongDTO?> UpdateAsync(int id, UpdateChuongResquestDTO updateDto)
        {
            var existingChuong = await _context.Chuongs.FindAsync(id);
            if (existingChuong == null)
            {
                return null;
            }

            existingChuong.Tenchuong = updateDto.Tenchuong;
            existingChuong.Mamonhoc = updateDto.Mamonhoc;
            existingChuong.Trangthai = updateDto.Trangthai;

            await _context.SaveChangesAsync();
            return existingChuong.ToChuongDto();
        }

        public async Task<bool> DeleteAsync(int id)
        {
            var chuongModel = await _context.Chuongs.FindAsync(id);
            if (chuongModel == null)
            {
                return false;
            }

            _context.Chuongs.Remove(chuongModel);
            await _context.SaveChangesAsync();
            return true;
        }
        
    }
}