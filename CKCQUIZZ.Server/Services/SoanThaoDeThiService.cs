using CKCQUIZZ.Server.Data;
using CKCQUIZZ.Server.Interfaces;
using CKCQUIZZ.Server.Models;
using CKCQUIZZ.Server.Viewmodels.SoanThao;
using Microsoft.EntityFrameworkCore;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace CKCQUIZZ.Server.Services
{
    public class SoanThaoDeThiService : ISoanThaoDeThiService
    {
        private readonly CkcquizzContext _context;

        public SoanThaoDeThiService(CkcquizzContext context)
        {
            _context = context;
        }

        public async Task<IEnumerable<CauHoiSoanThaoViewModel>> GetCauHoiCuaDeThiAsync(int deThiId)
        {
            var deThiExists = await _context.DeThis.AnyAsync(d => d.Made == deThiId);
            if (!deThiExists)
            {
                // Ném exception để controller bắt và trả về NotFound
                throw new KeyNotFoundException($"Không tìm thấy đề thi với ID = {deThiId}");
            }

            return await _context.ChiTietDeThis
                .Where(ct => ct.Made == deThiId)
                .Include(ct => ct.MacauhoiNavigation)
                .Select(ct => new CauHoiSoanThaoViewModel
                {
                    Macauhoi = ct.Macauhoi,
                    NoiDung = ct.MacauhoiNavigation.Noidung,
                    DoKho = MapDoKhoToString(ct.MacauhoiNavigation.Dokho)
                })
                .ToListAsync();
        }

        public async Task<int> AddCauHoiVaoDeThiAsync(int deThiId, DapAnSoanThaoViewModel request)
        {
            var deThi = await _context.DeThis.FindAsync(deThiId);
            if (deThi == null)
            {
                throw new KeyNotFoundException($"Không tìm thấy đề thi với ID = {deThiId}");
            }

            if (request?.CauHoiIds == null || !request.CauHoiIds.Any())
            {
                return 0; // Không có câu hỏi nào để thêm
            }

            var existingQuestionIds = await _context.ChiTietDeThis
                .Where(ct => ct.Made == deThiId)
                .Select(ct => ct.Macauhoi)
                .ToListAsync();
            
            var maxThuTu = await _context.ChiTietDeThis
                .Where(ct => ct.Made == deThiId)
                .Select(ct => (int?)ct.Thutu)
                .MaxAsync() ?? 0;

            var newQuestionIds = request.CauHoiIds.Except(existingQuestionIds).ToList();

            var validQuestionIds = await _context.CauHois
                .Where(ch => newQuestionIds.Contains(ch.Macauhoi))
                .Select(ch => ch.Macauhoi)
                .ToListAsync();

            if (!validQuestionIds.Any())
            {
                return 0;
            }

            var currentThuTu = maxThuTu;
            var chiTietDeThiList = validQuestionIds.Select(cauHoiId =>
            {
                currentThuTu++;
                return new ChiTietDeThi
                {
                    Made = deThiId,
                    Macauhoi = cauHoiId,
                    Diemcauhoi = 1,
                    Thutu = currentThuTu
                };
            }).ToList();

            await _context.ChiTietDeThis.AddRangeAsync(chiTietDeThiList);
            await _context.SaveChangesAsync();

            return chiTietDeThiList.Count;
        }

        public async Task<bool> RemoveCauHoiFromDeThiAsync(int deThiId, int cauHoiId)
        {
            var chiTietDeThi = await _context.ChiTietDeThis.FindAsync(deThiId, cauHoiId);

            if (chiTietDeThi == null)
            {
                return false; 
            }

            _context.ChiTietDeThis.Remove(chiTietDeThi);
            await _context.SaveChangesAsync();

            return true;
        }
        public async Task<bool> RemoveMultipleCauHoisFromDeThiAsync(int deThiId, List<int> cauHoiIds)
        {
            var chiTietDeThisToRemove = await _context.ChiTietDeThis
                .Where(ct => ct.Made == deThiId && cauHoiIds.Contains(ct.Macauhoi))
                .ToListAsync();
            if (chiTietDeThisToRemove == null || !chiTietDeThisToRemove.Any())
            {
                return false;
            }

            // Sử dụng RemoveRange để xóa nhiều bản ghi cùng lúc
            _context.ChiTietDeThis.RemoveRange(chiTietDeThisToRemove);
            await _context.SaveChangesAsync();
            return true;
        }
        private static string MapDoKhoToString(int dokho)
        {
            return dokho switch
            {
                1 => "Dễ",
                2 => "Trung bình",
                3 => "Khó",
                _ => "Không xác định"
            };
        }
    }
} 