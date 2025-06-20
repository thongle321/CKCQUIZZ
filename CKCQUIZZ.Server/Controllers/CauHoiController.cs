﻿using CKCQUIZZ.Server.Interfaces;
using CKCQUIZZ.Server.Viewmodels.CauHoi;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using System.Security.Claims;

namespace CKCQUIZZ.Server.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class CauHoiController : ControllerBase
    {
        private readonly ICauHoiService _cauHoiService;
        public CauHoiController(ICauHoiService cauHoiService) { _cauHoiService = cauHoiService; }

        [HttpGet]
        public async Task<IActionResult> GetAllPaging([FromQuery] QueryCauHoiDto query)
        {
            return Ok(await _cauHoiService.GetAllPagingAsync(query));
        }

        [HttpGet("{id}")]
        public async Task<IActionResult> GetById(int id)
        {
            var result = await _cauHoiService.GetByIdAsync(id);
            return result == null ? NotFound() : Ok(result);
        }

        [HttpPost]
        public async Task<IActionResult> Create([FromBody] CreateCauHoiRequestDto request)
        {
            var userId = User.FindFirstValue(ClaimTypes.NameIdentifier);
            if (string.IsNullOrEmpty(userId)) return Unauthorized();
            var newQuestionId = await _cauHoiService.CreateAsync(request, userId);
            return CreatedAtAction(nameof(GetById), new { id = newQuestionId }, new { id = newQuestionId });
        }

        [HttpPut("{id}")]
        public async Task<IActionResult> Update(int id, [FromBody] UpdateCauHoiRequestDto request)
        {
            var result = await _cauHoiService.UpdateAsync(id, request);
            if (!result) return NotFound($"Không tìm thấy câu hỏi có ID = {id} để cập nhật.");
            return NoContent();
        }
        [HttpDelete("{id}")]

        public async Task<IActionResult> Delete(int id)
        {
            var result = await _cauHoiService.DeleteAsync(id);
            if (!result)
            {
                return NotFound($"Không tìm thấy câu hỏi có ID = {id} để xóa.");
            }
            return NoContent(); // Trả về 204 No Content khi xóa thành công
        }
    }
}