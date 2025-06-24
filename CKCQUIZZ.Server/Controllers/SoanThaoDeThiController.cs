using CKCQUIZZ.Server.Interfaces;
using CKCQUIZZ.Server.Models;
using CKCQUIZZ.Server.Viewmodels.SoanThao; // Đảm bảo using đúng namespace ViewModel
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using System.Collections.Generic;
using System.Security.Claims;
using System.Threading.Tasks;

namespace CKCQUIZZ.Server.Controllers
{

    [Route("api/[controller]")]
    [ApiController]
    public class SoanThaoDeThiController : ControllerBase
    {
        private readonly CkcquizzContext _context;
        public SoanThaoDeThiController(CkcquizzContext context)
        {
            _context = context;
        }
        [HttpGet("{deThiId}/cauhoi")]
        public async Task<ActionResult<IEnumerable<CauHoiSoanThaoViewModel>>> GetCauHoiCuaDeThi(int deThiId)
        {
            // Kiểm tra xem đề thi có tồn tại không
            var deThiExists = await _context.DeThis.AnyAsync(d => d.Made == deThiId);
            if (!deThiExists)
            {
                return NotFound($"Không tìm thấy đề thi với ID = {deThiId}");
            }

            var questions = await _context.ChiTietDeThis
                .Where(ct => ct.Made == deThiId)
                .Include(ct => ct.MacauhoiNavigation) // Đảm bảo nạp dữ liệu từ bảng CauHoi
                .Select(ct => new CauHoiSoanThaoViewModel
                {
                    Macauhoi = ct.Macauhoi,
                    NoiDung = ct.MacauhoiNavigation.Noidung,
                    // Chuyển đổi độ khó từ số sang chữ
                    DoKho = MapDoKhoToString(ct.MacauhoiNavigation.Dokho)
                })
                .ToListAsync();

            return Ok(questions);
        }

        /// <summary>
        /// POST: /api/DeThi/{deThiId}/cauhoi
        /// Thêm một hoặc nhiều câu hỏi vào đề thi.
        /// </summary>
        [HttpPost("{deThiId}/cauhoi")]
        public async Task<IActionResult> AddCauHoiVaoDeThi(int deThiId, [FromBody] DapAnSoanThaoViewModel request)
        {
            // Kiểm tra xem đề thi có tồn tại không
            var deThi = await _context.DeThis.FindAsync(deThiId);
            if (deThi == null)
            {
                return NotFound($"Không tìm thấy đề thi với ID = {deThiId}");
            }

            if (request?.CauHoiIds == null || !request.CauHoiIds.Any())
            {
                return BadRequest("Danh sách ID câu hỏi không được rỗng.");
            }

            // Lấy danh sách ID các câu hỏi đã có trong đề để tránh thêm trùng lặp
            var existingQuestionIds = await _context.ChiTietDeThis
                .Where(ct => ct.Made == deThiId)
                .Select(ct => ct.Macauhoi)
                .ToListAsync();

            // Lọc ra những ID câu hỏi mới, chưa có trong đề
            var newQuestionIds = request.CauHoiIds.Except(existingQuestionIds).ToList();

            // Kiểm tra xem các câu hỏi mới có thực sự tồn tại trong CSDL không
            var validQuestionIds = await _context.CauHois
                .Where(ch => newQuestionIds.Contains(ch.Macauhoi))
                .Select(ch => ch.Macauhoi)
                .ToListAsync();

            if (!validQuestionIds.Any())
            {
                return Ok("Không có câu hỏi mới nào được thêm (có thể đã tồn tại hoặc ID không hợp lệ).");
            }

            var chiTietDeThiList = validQuestionIds.Select(cauHoiId => new ChiTietDeThi
            {
                Made = deThiId,
                Macauhoi = cauHoiId,
                Diemcauhoi = 0, // Giá trị mặc định, có thể thay đổi sau
                Thutu = 0       // Giá trị mặc định
            }).ToList();

            await _context.ChiTietDeThis.AddRangeAsync(chiTietDeThiList);
            await _context.SaveChangesAsync();

            return Ok(new { message = $"Đã thêm thành công {chiTietDeThiList.Count} câu hỏi vào đề thi." });
        }

        /// <summary>
        /// DELETE: /api/DeThi/{deThiId}/cauhoi/{cauHoiId}
        /// Xóa một câu hỏi cụ thể ra khỏi đề thi.
        /// </summary>
        [HttpDelete("{deThiId}/cauhoi/{cauHoiId}")]
        public async Task<IActionResult> RemoveCauHoiFromDeThi(int deThiId, int cauHoiId)
        {
            // Tìm bản ghi chi tiết đề thi cần xóa dựa vào composite key
            var chiTietDeThi = await _context.ChiTietDeThis.FindAsync(deThiId, cauHoiId);

            if (chiTietDeThi == null)
            {
                return NotFound($"Không tìm thấy câu hỏi có ID = {cauHoiId} trong đề thi có ID = {deThiId}.");
            }

            _context.ChiTietDeThis.Remove(chiTietDeThi);
            await _context.SaveChangesAsync();

            return NoContent(); // 204 No Content là response chuẩn cho một DELETE thành công
        }

        // Hàm helper để chuyển đổi độ khó
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