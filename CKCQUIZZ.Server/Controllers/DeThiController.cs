using System.Security.Claims;
using CKCQUIZZ.Server.Interfaces;
using CKCQUIZZ.Server.Viewmodels.DeThi;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using CKCQUIZZ.Server.Authorization; // Add this using statement

namespace CKCQUIZZ.Server.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class DeThiController(IDeThiService _deThiService) : ControllerBase
    {
        private string GetCurrentUserId()
        {
            return User.FindFirstValue(ClaimTypes.NameIdentifier)
                              ?? throw new UnauthorizedAccessException("Không thể xác định người dùng. Vui lòng đăng nhập lại.");
        }
        [HttpGet]
        [Permission(Permissions.DeThi.View)]
        public async Task<IActionResult> GetAll()
        {
            var currentUserId = GetCurrentUserId();
            var result = await _deThiService.GetAllByTeacherAsync(currentUserId);
            return Ok(result);
        }

        [HttpGet("{id}")]
        [Permission(Permissions.DeThi.View)]
        public async Task<IActionResult> GetById(int id)
        {
            var result = await _deThiService.GetByIdAsync(id);
            if (result == null) return NotFound();
            return Ok(result);
        }

        [HttpPost]
        [Authorize]
        [Permission(Permissions.DeThi.Create)]
        public async Task<IActionResult> Create([FromBody] DeThiCreateRequest request)
        {
            if (!ModelState.IsValid) return BadRequest(ModelState);
            var result = await _deThiService.CreateAsync(request);
            return CreatedAtAction(nameof(GetById), new { id = result.Made }, result);
        }

        [HttpPut("{id}")]
        [Permission(Permissions.DeThi.Update)]
        public async Task<IActionResult> Update(int id, [FromBody] DeThiUpdateRequest request)
        {
            if (!ModelState.IsValid) return BadRequest(ModelState);
            var result = await _deThiService.UpdateAsync(id, request);
            if (!result) return NotFound();
            return NoContent(); // Trả về 204 No Content khi cập nhật thành công
        }

        [HttpDelete("{id}")]
        [Permission(Permissions.DeThi.Delete)]
        public async Task<IActionResult> Delete(int id)
        {
            var result = await _deThiService.DeleteAsync(id);
            if (!result) return NotFound();
            return NoContent(); // Trả về 204 No Content khi xóa thành công
        }
        [HttpPost("{maDe}/cap-nhat-chi-tiet")]
        public async Task<IActionResult> CapNhatChiTietDeThi(int maDe, [FromBody] CapNhatChiTietDeThiRequest request)
        {
            if (!ModelState.IsValid)
            {
                return BadRequest(ModelState);
            }

            var result = await _deThiService.CapNhatChiTietDeThiAsync(maDe, request);

            if (!result)
            {
                return NotFound(new { message = $"Không tìm thấy đề thi với mã {maDe}." });
            }

            return Ok(new { message = "Cập nhật đề thi thành công!" });
        }

        [HttpGet("class/{classId}")] 
        public async Task<IActionResult> GetExamsForClass(int classId)
        {
            var studentId = GetCurrentUserId();

            var result = await _deThiService.GetExamsForClassAsync(classId, studentId);

            if (result == null)
            {
                return Ok(new List<ExamForClassDto>());
            }
            return Ok(result);
        }

        [HttpGet("my-exams")]
        public async Task<IActionResult> GetAllMyExams()
        {
            try
            {
                var studentId = GetCurrentUserId();
                var result = await _deThiService.GetAllExamsForStudentAsync(studentId);
                return Ok(result);
            }
            catch (UnauthorizedAccessException ex)
            {
                return Unauthorized(new { message = ex.Message });
            }
        }

        [HttpGet("{examId}/questions-for-student")]
        public async Task<IActionResult> GetQuestionsForStudent(int examId)
        {
            try
            {
                var studentId = GetCurrentUserId();
                var result = await _deThiService.GetQuestionsForStudentAsync(examId, studentId);
                return Ok(result);
            }
            catch (UnauthorizedAccessException ex)
            {
                return Unauthorized(new { message = ex.Message });
            }
            catch (ArgumentException ex)
            {
                return BadRequest(new { message = ex.Message });
            }
        }
    }
}