using CKCQUIZZ.Server.Authorization;
using CKCQUIZZ.Server.Interfaces;
using CKCQUIZZ.Server.Validators.DeThi;
using CKCQUIZZ.Server.Viewmodels.DeThi;
using FluentValidation;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using System.Security.Claims;

namespace CKCQUIZZ.Server.Controllers
{

    public class DeThiController(IDeThiService _deThiService) : BaseController
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
            var result = await _deThiService.GetAllAsync();
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
        [Permission(Permissions.DeThi.Create)]
        public async Task<IActionResult> Create([FromBody] DeThiCreateRequest request, IValidator<DeThiCreateRequest> _validator)
        {
            var validationResult = await _validator.ValidateAsync(request);
            if (!validationResult.IsValid)
            {
                var problemDetails = new HttpValidationProblemDetails(validationResult.ToDictionary())
                {
                    Status = StatusCodes.Status400BadRequest,
                    Title = "Lỗi xác thực dữ liệu",
                    Instance = HttpContext.Request.Path
                };
                return BadRequest(problemDetails);
            }
            var result = await _deThiService.CreateAsync(request);
            return CreatedAtAction(nameof(GetById), new { id = result.Made }, result);
        }

        [HttpPut("{id}")]
        [Permission(Permissions.DeThi.Update)]
        public async Task<IActionResult> Update(int id, [FromBody] DeThiUpdateRequest request)
        {
            try
            {
                if (!ModelState.IsValid) return BadRequest(ModelState);
                var result = await _deThiService.UpdateAsync(id, request);
                if (!result) return NotFound();
                return NoContent();
            }
            catch (UnauthorizedAccessException ex) 
            {
                return StatusCode(StatusCodes.Status403Forbidden, new { message = ex.Message });
            }
           
        }
        [HttpDelete("{id}")]
        [Permission(Permissions.DeThi.Delete)]
        public async Task<IActionResult> Delete(int id)
        {
            try
            {
                var result = await _deThiService.DeleteAsync(id);
                if (!result) return NotFound();
                return NoContent();
            }
            catch (UnauthorizedAccessException ex)
            {
                return StatusCode(StatusCodes.Status403Forbidden, new { message = ex.Message });
            }

        }
        [HttpPut("Restore/{id}")]
        [Permission(Permissions.DeThi.Update)]
        public async Task<IActionResult> Restore(int id)
        {
            try
            {
                var result = await _deThiService.RestoreAsync(id);
                if (!result) return NotFound();
                return NoContent();
            }
            catch (UnauthorizedAccessException ex)
            {
                return StatusCode(StatusCodes.Status403Forbidden, new { message = ex.Message });
            }
        }
        [HttpDelete("{id}/HardDelete")]
        [Permission(Permissions.DeThi.Delete)]
        public async Task<IActionResult> HardDelete(int id)
        {
            try
            {
                var result = await _deThiService.HardDeleteAsync(id);
                if (!result) return NotFound(new { message = $"Không tìm thấy đề thi." });
                return NoContent();
            }
            catch (UnauthorizedAccessException ex)
            {
                return StatusCode(StatusCodes.Status403Forbidden, new { message = ex.Message });
            }
            catch (InvalidOperationException ex)
            {
                return StatusCode(StatusCodes.Status409Conflict, new { message = ex.Message });
            }
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

        [HttpPut("{id}/toggle-status")]
        [Permission(Permissions.DeThi.Update)]
        public async Task<IActionResult> ToggleExamStatus(int id, [FromQuery] bool trangthai)
        {
            try
            {
                var result = await _deThiService.ToggleExamStatusAsync(id, trangthai);
                if (!result)
                {
                    return NotFound(new { message = "Không tìm thấy đề thi để cập nhật trạng thái." });
                }
                return Ok(new { message = "Cập nhật trạng thái đề thi thành công." });
            }
            catch (UnauthorizedAccessException ex)
            {
                return StatusCode(StatusCodes.Status403Forbidden, new { message = ex.Message });
            }
            catch (Exception ex)
            {
                return StatusCode(StatusCodes.Status500InternalServerError, new { message = $"Lỗi server: {ex.Message}" });
            }
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


        [HttpGet("my-created-exams")]
        [Permission(Permissions.DeThi.View)]
        public async Task<IActionResult> GetMyCreatedExams()
        {
            try
            {
                var teacherId = GetCurrentUserId();
                var result = await _deThiService.GetMyCreatedExamsAsync(teacherId);
                return Ok(result);
            }
            catch (UnauthorizedAccessException ex)
            {
                return Unauthorized(new { message = ex.Message });
            }
        }
        [HttpGet("results/{id}")]
        [Permission(Permissions.DeThi.View)]
        public async Task<IActionResult> GetTestResults(int id)
        {
            var result = await _deThiService.GetTestResultsAsync(id);
            if (result == null)
            {
                return NotFound($"Không tìm thấy đề thi có ID = {id}.");
            }
            return Ok(result);
        }
    }
}