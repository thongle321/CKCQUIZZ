// Controllers/DeThiController.cs
using CKCQUIZZ.Server.Interfaces;
using CKCQUIZZ.Server.Viewmodels.DeThi;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace CKCQUIZZ.Server.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class DeThiController : ControllerBase
    {
        private readonly IDeThiService _deThiService;

        public DeThiController(IDeThiService deThiService)
        {
            _deThiService = deThiService;
        }

        [HttpGet]
        public async Task<IActionResult> GetAll()
        {
            var result = await _deThiService.GetAllAsync();
            return Ok(result);
        }

        [HttpGet("{id}")]
        public async Task<IActionResult> GetById(int id)
        {
            var result = await _deThiService.GetByIdAsync(id);
            if (result == null) return NotFound();
            return Ok(result);
        }

        [HttpPost]
        [Authorize]
        public async Task<IActionResult> Create([FromBody] DeThiCreateRequest request)
        {
            if (!ModelState.IsValid) return BadRequest(ModelState);
            var result = await _deThiService.CreateAsync(request);
            return CreatedAtAction(nameof(GetById), new { id = result.Made }, result);
        }

        [HttpPut("{id}")]
        public async Task<IActionResult> Update(int id, [FromBody] DeThiUpdateRequest request)
        {
            if (!ModelState.IsValid) return BadRequest(ModelState);
            var result = await _deThiService.UpdateAsync(id, request);
            if (!result) return NotFound();
            return NoContent(); // Trả về 204 No Content khi cập nhật thành công
        }

        [HttpDelete("{id}")]
        public async Task<IActionResult> Delete(int id)
        {
            var result = await _deThiService.DeleteAsync(id);
            if (!result) return NotFound();
            return NoContent(); // Trả về 204 No Content khi xóa thành công
        }
    }
}