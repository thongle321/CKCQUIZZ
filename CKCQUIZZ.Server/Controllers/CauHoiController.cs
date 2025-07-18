﻿using CKCQUIZZ.Server.Interfaces;
using CKCQUIZZ.Server.Viewmodels.CauHoi;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using System.Security.Claims;
using CKCQUIZZ.Server.Authorization;

namespace CKCQUIZZ.Server.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class CauHoiController(ICauHoiService _cauHoiService) : ControllerBase
    {

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
            try
            {
                var userId = User.FindFirstValue(ClaimTypes.NameIdentifier);
                if (string.IsNullOrEmpty(userId))
                    return Unauthorized();
                 await _cauHoiService.UpdateAsync(id, request, userId);
                return NoContent();
            }
            catch (UnauthorizedAccessException ex)
            {
                return BadRequest(ex.Message);
            }
            catch(InvalidOperationException ex)
            {
                return BadRequest(ex.Message);
            }

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
            return NoContent();
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

        [HttpGet("my-created-questions")]
        [Permission(Permissions.CauHoi.View)]
        public async Task<IActionResult> GetMyCreatedQuestions([FromQuery] QueryCauHoiDto query)
        {
            var userId = User.FindFirstValue(ClaimTypes.NameIdentifier);
            if (string.IsNullOrEmpty(userId)) return Unauthorized();

            var result = await _cauHoiService.GetMyCreatedQuestionsAsync(userId, query);
            return Ok(result);
        }
        [HttpDelete("{id}/permanent")]
        [Permission(Permissions.CauHoi.Delete)]
        public async Task<IActionResult> HardDelete(int id)
        {
            var userId = User.FindFirstValue(ClaimTypes.NameIdentifier);
            if (string.IsNullOrEmpty(userId)) return Unauthorized();
            var (success, message) = await _cauHoiService.HardDeleteAsync(id,userId);

            if (success)
            {
                return Ok(new { message });
            }

            // Kiểm tra xem có phải lỗi do không có quyền không
            if (message.Contains("không có quyền"))
            {
                return BadRequest(new { message }); // Trả về 403 Forbidden
            }

            // Các lỗi khác
            return BadRequest(new { message });
        }

    }
}