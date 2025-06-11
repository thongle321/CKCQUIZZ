using CKCQUIZZ.Server.Services.Interfaces;
using CKCQUIZZ.Server.Viewmodels.Chuong;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace CKCQUIZZ.Server.Controllers
{
    public class ChuongController : BaseController
    {
        private readonly IChuongService _chuongService;

        public ChuongController(IChuongService chuongService)
        {
            _chuongService = chuongService;
        }

        // GET: api/chuong
        [HttpGet]
        [AllowAnonymous]
        public async Task<IActionResult> GetAll([FromQuery] int? mamonhocId)
        {
            var chuongs = await _chuongService.GetAllAsync(mamonhocId);
            return Ok(chuongs);
        }

        // GET: api/chuong/{id}
        [HttpGet("{id}")]
        public async Task<IActionResult> GetById([FromRoute] int id)
        {
            var chuong = await _chuongService.GetByIdAsync(id);
            if (chuong == null)
            {
                return NotFound();
            }
            return Ok(chuong);
        }

        // POST: api/chuong
        [HttpPost]
        public async Task<IActionResult> Create([FromBody] CreateChuongRequestDTO createDto)
        {
            if (!ModelState.IsValid)
            {
                return BadRequest(ModelState);
            }

            var newChuong = await _chuongService.CreateAsync(createDto);
            // Trả về endpoint để lấy thông tin chương vừa tạo
            return CreatedAtAction(nameof(GetById), new { id = newChuong.Machuong }, newChuong);
        }

        // PUT: api/chuong/{id}
        [HttpPut("{id}")]
        public async Task<IActionResult> Update([FromRoute] int id, [FromBody] UpdateChuongResquestDTO updateDto)
        {
            if (!ModelState.IsValid)
            {
                return BadRequest(ModelState);
            }

            var updatedChuong = await _chuongService.UpdateAsync(id, updateDto);
            if (updatedChuong == null)
            {
                return NotFound("Không tìm thấy chương để cập nhật.");
            }
            return Ok(updatedChuong);
        }

        [HttpDelete("{id}")]
        public async Task<IActionResult> Delete([FromRoute] int id)
        {
            var result = await _chuongService.DeleteAsync(id);
            if (!result)
            {
                return NotFound("Không tìm thấy chương để xóa.");
            }
            return NoContent(); // Trả về 204 No Content khi xóa thành công
        }
    }
}