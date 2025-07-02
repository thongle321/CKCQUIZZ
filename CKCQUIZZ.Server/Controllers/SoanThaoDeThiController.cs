using Microsoft.AspNetCore.Mvc;
using CKCQUIZZ.Server.Interfaces;
using CKCQUIZZ.Server.Viewmodels.SoanThao;
using System.Threading.Tasks;
using System.Collections.Generic;

namespace CKCQUIZZ.Server.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class SoanThaoDeThiController(ISoanThaoDeThiService _soanThaoDeThiService) : ControllerBase
    {
        [HttpGet("{deThiId}/cauhoi")]
        public async Task<IActionResult> GetCauHoiCuaDeThi(int deThiId)
        {
            try
            {
                var cauHois = await _soanThaoDeThiService.GetCauHoiCuaDeThiAsync(deThiId);
                return Ok(cauHois);
            }
            catch (KeyNotFoundException ex)
            {
                return NotFound(ex.Message);
            }
        }

        [HttpPost("{deThiId}/cauhoi")]
        public async Task<IActionResult> AddCauHoiVaoDeThi(int deThiId, [FromBody] DapAnSoanThaoViewModel request)
        {
            if (request == null || request.CauHoiIds == null || request.CauHoiIds.Count == 0)
            {
                return BadRequest("Request không hợp lệ hoặc không chứa câu hỏi nào.");
            }
            try
            {
                var soLuongCauHoiDaThem = await _soanThaoDeThiService.AddCauHoiVaoDeThiAsync(deThiId, request);
                if (soLuongCauHoiDaThem == 0)
                {
                    return Ok("Không có câu hỏi mới nào được thêm (có thể đã tồn tại hoặc không hợp lệ).");
                }
                return Ok($"Đã thêm thành công {soLuongCauHoiDaThem} câu hỏi vào đề thi.");
            }
            catch (KeyNotFoundException ex)
            {
                return NotFound(ex.Message);
            }
        }

        [HttpDelete("{deThiId}/cauhoi/{cauHoiId}")]
        public async Task<IActionResult> RemoveCauHoiFromDeThi(int deThiId, int cauHoiId)
        {
            var success = await _soanThaoDeThiService.RemoveCauHoiFromDeThiAsync(deThiId, cauHoiId);
            if (!success)
            {
                return NotFound("Không tìm thấy câu hỏi này trong đề thi.");
            }
            return NoContent();
        }
        [HttpDelete("{deThiId}/cauhoi")]
        public async Task<IActionResult> RemoveMultipleCauHoisFromDeThi(int deThiId, [FromBody] DapAnSoanThaoViewModel request)
        {
            if (request == null || request.CauHoiIds == null || request.CauHoiIds.Count == 0)
            {
                return BadRequest("Yêu cầu không hợp lệ hoặc danh sách ID câu hỏi rỗng.");
            }
            try
            {
                var success = await _soanThaoDeThiService.RemoveMultipleCauHoisFromDeThiAsync(deThiId, request.CauHoiIds);
                if (!success)
                {
                    return NotFound("Không tìm thấy câu hỏi nào trong danh sách đã cho để xóa khỏi đề thi này.");
                }
                return NoContent();
            }
            catch (Exception)
            {
                return StatusCode(500, "Đã xảy ra lỗi nội bộ máy chủ khi đang xử lý yêu cầu của bạn.");
            }
        }
    }
}
