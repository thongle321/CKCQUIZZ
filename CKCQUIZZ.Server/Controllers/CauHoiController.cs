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
            return Ok(await _cauHoiService.GetAllPagingAsync(query));
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
            var result = await _cauHoiService.GetByMaMonHocAsync(monHocId);
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
        [HttpPost("import-from-zip")]
        [Permission(Permissions.CauHoi.Create)] // Tái sử dụng quyền Create
        [RequestSizeLimit(100_000_000)]
        public async Task<IActionResult> ImportFromZip(
        [FromForm] IFormFile file,
        [FromQuery] int maMonHoc, // <<< Đã là INT để khớp với toàn hệ thống
        [FromQuery] int maChuong,
        [FromQuery] int doKho)
        {
            // 1. Kiểm tra đầu vào cơ bản
            if (file == null || file.Length == 0)
            {
                return BadRequest("Vui lòng tải lên một file .zip.");
            }
            if (maMonHoc <= 0 || maChuong <= 0)
            {
                return BadRequest("Vui lòng chọn Môn học và Chương.");
            }

            // 2. Lấy thông tin người dùng đang đăng nhập
            var userId = User.FindFirstValue(ClaimTypes.NameIdentifier);
            if (string.IsNullOrEmpty(userId))
            {
                return Unauthorized();
            }

            // 3. Gọi đến service để xử lý nghiệp vụ
            var result = await _cauHoiService.ImportFromZipAsync(file, maMonHoc, maChuong, doKho, userId);

            // 4. Xử lý kết quả trả về từ service
            if (result.DanhSachLoi.Any())
            {
                // Nếu có lỗi, trả về mã 400 (Bad Request) kèm theo thông tin lỗi
                return BadRequest(result);
            }

            // Nếu không có lỗi, trả về mã 200 (OK) kèm theo kết quả thành công
            return Ok(result);
        }
    }
}