using CKCQUIZZ.Server.Interfaces;
using CKCQUIZZ.Server.Models;
using CKCQUIZZ.Server.Viewmodels.Lop;
using Microsoft.EntityFrameworkCore;


public class LopService(CkcquizzContext _context) : ILopService
{

    public async Task<List<LopDTO>> GetAllAsync()
    {
        return (await _context.Lops.ToListAsync()).Select(LopMappers.ToDto).ToList();
    }

    public async Task<LopDTO?> GetByIdAsync(int id)
    {
        var entity = await _context.Lops.FindAsync(id);
        return entity != null ? LopMappers.ToDto(entity) : null;
    }

    public async Task<LopDTO> CreateAsync(LopDTO dto)
    {
        var entity = LopMappers.ToEntity(dto);
        _context.Lops.Add(entity);
        await _context.SaveChangesAsync();
        return LopMappers.ToDto(entity);
    }

    public async Task<bool> UpdateAsync(int id, LopDTO dto)
    {
        var entity = await _context.Lops.FindAsync(id);
        if (entity == null) return false;
        LopMappers.UpdateEntity(entity, dto);
        await _context.SaveChangesAsync();
        return true;
    }

    public async Task<bool> DeleteAsync(int id)
    {
        var entity = await _context.Lops.FindAsync(id);
        if (entity == null) return false;
        _context.Lops.Remove(entity);
        await _context.SaveChangesAsync();
        return true;
    }
}
