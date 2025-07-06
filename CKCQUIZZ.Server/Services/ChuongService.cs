using CKCQUIZZ.Server.Mappers;
using CKCQUIZZ.Server.Models;
using CKCQUIZZ.Server.Interfaces;
using CKCQUIZZ.Server.Viewmodels.Chuong;
using Microsoft.EntityFrameworkCore;
namespace CKCQUIZZ.Server.Services
{
    public class ChuongService : IChuongService
    {
        private readonly CkcquizzContext _context;

        public ChuongService(CkcquizzContext context)
        {
            _context = context;
        }

        public async Task<List<ChuongDTO>> GetAllAsync(int? mamonhocId, string userId)
        {
            var query = _context.Chuongs
            .Where(c => c.Nguoitao == userId)
            .AsQueryable();

            if (mamonhocId.HasValue && mamonhocId.Value > 0)
            {
                query = query.Where(c => c.Mamonhoc == mamonhocId.Value);
            }

            var result = await query
                .Select(c => c.ToChuongDto())
                .ToListAsync();

            return result;
        }

        public async Task<ChuongDTO?> GetByIdAsync(int id, string userId)
        {
            var chuong = await _context.Chuongs.FirstOrDefaultAsync(c => c.Machuong == id && c.Nguoitao == userId);
            if (chuong == null)
            {
                return null;
            }
            return chuong?.ToChuongDto();
        }

        public async Task<ChuongDTO> CreateAsync(CreateChuongRequestDTO createDto, string userId)
        {
            var chuongModel = createDto.ToChuongFromCreateDto();
            chuongModel.Nguoitao = userId;

            await _context.Chuongs.AddAsync(chuongModel);
            await _context.SaveChangesAsync();
            return chuongModel.ToChuongDto();
        }

        public async Task<ChuongDTO?> UpdateAsync(int id, UpdateChuongResquestDTO updateDto, string userId)
        {
            var existingChuong = await _context.Chuongs.FirstOrDefaultAsync(c => c.Machuong == id && c.Nguoitao == userId);
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

        public async Task<bool> DeleteAsync(int id, string userId)
        {
            var chuongModel = await _context.Chuongs.FirstOrDefaultAsync(c => c.Machuong == id && c.Nguoitao == userId);
            if (chuongModel == null)
            {
                return false;
            }

            chuongModel.Trangthai = false;
            _context.Entry(chuongModel).State = EntityState.Modified;
            return await _context.SaveChangesAsync() > 0;
        }
        
    }
}