using CKCQUIZZ.Server.Interfaces;
using CKCQUIZZ.Server.Viewmodels.CauHoi;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using System.Security.Claims;
using CKCQUIZZ.Server.Authorization; // Add this using statement

namespace CKCQUIZZ.Server.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class CauHoiController : ControllerBase
    {
        private readonly ICauHoiService _cauHoiService;
        public CauHoiController(ICauHoiService cauHoiService) { _cauHoiService = cauHoiService; }

        [HttpGet]
        [Permission(Permissions.CauHoi.View)]
        public async Task<IActionResult> GetAllPaging([FromQuery] QueryCauHoiDto query)
        {
            // Automatically filter by current user - each teacher only sees their own questions
            var userId = User.FindFirstValue(ClaimTypes.NameIdentifier);

            // DEBUG: Log user information
            Console.WriteLine($"🔍 DEBUG GetAllPaging - User ID from JWT: '{userId}'");
            Console.WriteLine($"🔍 DEBUG GetAllPaging - Query before filter: MaMonHoc={query.MaMonHoc}, NguoiTao='{query.NguoiTao}'");

            if (string.IsNullOrEmpty(userId))
            {
                Console.WriteLine("❌ DEBUG GetAllPaging - User ID is null or empty, returning Unauthorized");
                return Unauthorized();
            }

            query.NguoiTao = userId;
            Console.WriteLine($"🔍 DEBUG GetAllPaging - Query after filter: MaMonHoc={query.MaMonHoc}, NguoiTao='{query.NguoiTao}'");

            var result = await _cauHoiService.GetAllPagingAsync(query);
            Console.WriteLine($"🔍 DEBUG GetAllPaging - Result count: {result.TotalCount}");

            return Ok(result);
        }

        [HttpGet("{id}")]
        [Permission(Permissions.CauHoi.View)]
        public async Task<IActionResult> GetById(int id)
        {
            var result = await _cauHoiService.GetByIdAsync(id);
            return result == null ? NotFound() : Ok(result);
        }

        [HttpPost]
        [Permission(Permissions.CauHoi.Create)]
        public async Task<IActionResult> Create([FromBody] CreateCauHoiRequestDto request)
        {
            var userId = User.FindFirstValue(ClaimTypes.NameIdentifier);
            if (string.IsNullOrEmpty(userId)) return Unauthorized();
            var newQuestionId = await _cauHoiService.CreateAsync(request, userId);
            return CreatedAtAction(nameof(GetById), new { id = newQuestionId }, new { id = newQuestionId });
        }

        [HttpPut("{id}")]
        [Permission(Permissions.CauHoi.Update)]
        public async Task<IActionResult> Update(int id, [FromBody] UpdateCauHoiRequestDto request)
        {
            var result = await _cauHoiService.UpdateAsync(id, request);
            if (!result) return NotFound($"Không tìm thấy câu hỏi có ID = {id} để cập nhật.");
            return NoContent();
        }
        [HttpDelete("{id}")]
        [Permission(Permissions.CauHoi.Delete)]
        public async Task<IActionResult> Delete(int id)
        {
            var result = await _cauHoiService.DeleteAsync(id);
            if (!result)
            {
                return NotFound($"Không tìm thấy câu hỏi có ID = {id} để xóa.");
            }
            return NoContent(); // Trả về 204 No Content khi xóa thành công
        }
        [HttpGet("ByMonHoc/{monHocId:int}")]
        public async Task<ActionResult<List<CauHoiDetailDto>>> GetByMonHoc(int monHocId)
        {
            var userId = User.FindFirstValue(ClaimTypes.NameIdentifier);
            if (string.IsNullOrEmpty(userId)) return Unauthorized();

            var result = await _cauHoiService.GetByMaMonHocAsync(monHocId, userId);
            return Ok(result);
        }
        [HttpGet("for-my-subjects")]
        [Permission(Permissions.CauHoi.View)]
        public async Task<IActionResult> GetForMySubjects([FromQuery] QueryCauHoiDto query)
        {
            var userId = User.FindFirstValue(ClaimTypes.NameIdentifier);
            if (string.IsNullOrEmpty(userId)) return Unauthorized();

            var result = await _cauHoiService.GetQuestionsForAssignedSubjectsAsync(userId, query);
            return Ok(result);
        }
    }
}