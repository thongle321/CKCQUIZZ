using System.Security.Claims;
using CKCQUIZZ.Server.Interfaces;
using CKCQUIZZ.Server.Viewmodels.Chuong;
using FluentValidation;
using Microsoft.AspNetCore.Mvc;
using CKCQUIZZ.Server.Authorization; // Add this using statement

namespace CKCQUIZZ.Server.Controllers
{
    public class ChuongController(IChuongService _chuongService) : BaseController
    {
        private string GetCurrentUserId()
        {
            return User.FindFirstValue(ClaimTypes.NameIdentifier) ?? throw new Exception("Người dùng không xác thực");
        }
        [HttpGet]
        [Permission(Permissions.Chuong.View)]
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
        [Permission(Permissions.Chuong.View)]
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
        [Permission(Permissions.Chuong.Create)]
        public async Task<IActionResult> Create([FromBody] CreateChuongRequestDTO request, IValidator<CreateChuongRequestDTO> _validator)
        {
            var userId = GetCurrentUserId();
            var validationResult = await _validator.ValidateAsync(request);
            if (string.IsNullOrEmpty(userId))
            {
                return Unauthorized("Không thể xác định người dùng.");
            }
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
            var newChuong = await _chuongService.CreateAsync(request, userId);
            return CreatedAtAction(nameof(GetById), new { id = newChuong.Machuong }, newChuong);
        }

        [HttpPut("{id}")]
        [Permission(Permissions.Chuong.Update)]
        public async Task<IActionResult> Update([FromRoute] int id, [FromBody] UpdateChuongResquestDTO request, IValidator<UpdateChuongResquestDTO> _validator)
        {
            var userId = GetCurrentUserId();
            var validationResult = await _validator.ValidateAsync(request);
            if (string.IsNullOrEmpty(userId))
            {
                return Unauthorized("Không thể xác định người dùng.");
            }
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
            var updatedChuong = await _chuongService.UpdateAsync(id, request, userId);

            if (updatedChuong == null)
            {
                return NotFound("Không tìm thấy chương để cập nhật.");
            }
            return Ok(updatedChuong);
        }

        [HttpDelete("{id}")]
        [Permission(Permissions.Chuong.Delete)]
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