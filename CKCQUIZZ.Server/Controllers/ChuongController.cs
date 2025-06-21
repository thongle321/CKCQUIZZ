using System.Security.Claims;
using CKCQUIZZ.Server.Interfaces;
using CKCQUIZZ.Server.Viewmodels.Chuong;
using Microsoft.AspNetCore.Mvc;

namespace CKCQUIZZ.Server.Controllers
{
    public class ChuongController(IChuongService _chuongService) : BaseController
    {
        private string GetCurrentUserId()
        {
            return User.FindFirstValue(ClaimTypes.NameIdentifier) ?? throw new Exception("Người dùng không xác thực");
        }
        [HttpGet]
        public async Task<IActionResult> GetAll([FromQuery] int? mamonhocId)
        {
            var userId = GetCurrentUserId();
            if (string.IsNullOrEmpty(userId))
            {
                return Unauthorized("Không thể xác định người dùng.");
            }

            var chuongs = await _chuongService.GetAllAsync(mamonhocId, userId);
            return Ok(chuongs);
        }

        [HttpGet("{id}")]
        public async Task<IActionResult> GetById([FromRoute] int id)
        {
            var userId = GetCurrentUserId();
            if (string.IsNullOrEmpty(userId))
            {
                return Unauthorized("Không thể xác định người dùng.");
            }
            var chuong = await _chuongService.GetByIdAsync(id, userId);
            if (chuong == null)
            {
                return NotFound();
            }
            return Ok(chuong);
        }

        [HttpPost]
        public async Task<IActionResult> Create([FromBody] CreateChuongRequestDTO createDto)
        {
            var userId = GetCurrentUserId();
            if (string.IsNullOrEmpty(userId))
            {
                return Unauthorized("Không thể xác định người dùng.");
            }
            if (!ModelState.IsValid)
            {
                return BadRequest(ModelState);
            }

            var newChuong = await _chuongService.CreateAsync(createDto, userId);
            return CreatedAtAction(nameof(GetById), new { id = newChuong.Machuong }, newChuong);
        }

        [HttpPut("{id}")]
        public async Task<IActionResult> Update([FromRoute] int id, [FromBody] UpdateChuongResquestDTO updateDto)
        {
            var userId = GetCurrentUserId();
            if (string.IsNullOrEmpty(userId))
            {
                return Unauthorized("Không thể xác định người dùng.");
            }
            if (!ModelState.IsValid)
            {
                return BadRequest(ModelState);
            }
            var updatedChuong = await _chuongService.UpdateAsync(id, updateDto, userId);

            if (updatedChuong == null)
            {
                return NotFound("Không tìm thấy chương để cập nhật.");
            }
            return Ok(updatedChuong);
        }

        [HttpDelete("{id}")]
        public async Task<IActionResult> Delete([FromRoute] int id)
        {
            var userId = GetCurrentUserId();
            var result = await _chuongService.DeleteAsync(id, userId);
            if (!result)
            {
                return NotFound("Không tìm thấy chương để xóa.");
            }
            return NoContent(); 
        }
    }
}