using CKCQUIZZ.Server.Interfaces;
using CKCQUIZZ.Server.Viewmodels.Permission;
using Microsoft.AspNetCore.Mvc;

namespace CKCQUIZZ.Server.Controllers
{
    public class PermissionController(IPermissionService _permissionService) : BaseController
    {

        [HttpGet]
        public async Task<IActionResult> GetAllPermissionGroups()
        {
            var result = await _permissionService.GetAllAsync();
            return Ok(result);
        }

        [HttpGet("{id}")]
        public async Task<IActionResult> GetPermissionGroupById(string id)
        {
            var result = await _permissionService.GetByIdAsync(id);
            if (result == null) return NotFound();
            
            return Ok(result);
        }

        [HttpPost]
        public async Task<IActionResult> CreatePermissionGroup([FromBody] PermissionScreenDTO dto)
        {
            var result = await _permissionService.CreateAsync(dto);
            if (!result.Succeeded)
            {
                return BadRequest(result.Errors);
            }
            return CreatedAtAction(nameof(GetPermissionGroupById), new { id = dto.Id }, dto);
        }

        [HttpPut("{id}")]
        public async Task<IActionResult> UpdatePermissionGroup(string id, [FromBody] PermissionScreenDTO dto)
        {
            if (id != dto.Id) return BadRequest("ID không khớp.");

            var result = await _permissionService.UpdateAsync(dto);
            if (!result.Succeeded)
            {
                // Có thể trả về NotFound nếu không tìm thấy, hoặc BadRequest nếu có lỗi khác
                return BadRequest(result.Errors);
            }
            return NoContent(); // HTTP 204 No Content - Thành công
        }

        [HttpDelete("{id}")]
        public async Task<IActionResult> DeletePermissionGroup(string id)
        {
            var result = await _permissionService.DeleteAsync(id);
            if (!result) return NotFound();
            return NoContent();
        }

        [HttpGet("functions")]
        public async Task<IActionResult> GetAllFunctions()
        {
            var functions = await _permissionService.GetFunctionsAsync();
            return Ok(functions);
        }
    }
}
