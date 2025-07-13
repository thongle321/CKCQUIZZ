using CKCQUIZZ.Server.Interfaces;
using CKCQUIZZ.Server.Models;
using CKCQUIZZ.Server.Viewmodels.NguoiDung;
using Microsoft.AspNetCore.Mvc;
using CKCQUIZZ.Server.Viewmodels;
using CKCQUIZZ.Server.Authorization;

namespace CKCQUIZZ.Server.Controllers
{
    public class UserSearchController(INguoiDungService _nguoiDungService) : BaseController
    {
        [HttpGet("search")]
        [Permission(Permissions.NguoiDung.View)]
        public async Task<ActionResult<PagedResult<GetNguoiDungDTO>>> SearchUsers(
            [FromQuery] string? query = null,
            [FromQuery] int page = 1,
            [FromQuery] int pageSize = 10,
            [FromQuery] string? role = null)
        {
            try
            {
                var users = await _nguoiDungService.GetAllAsync(page, pageSize, query, role);
                return Ok(users);
            }
            catch (Exception ex)
            {
                return StatusCode(500, new { message = "An error occurred while searching users", error = ex.Message });
            }
        }

        [HttpGet("find/{identifier}")]
        [Permission(Permissions.NguoiDung.View)]
        public async Task<ActionResult<NguoiDung>> FindUser(string identifier)
        {
            try
            {
                if (string.IsNullOrWhiteSpace(identifier))
                {
                    return BadRequest(new { message = "Identifier is required" });
                }

                var user = await _nguoiDungService.GetByIdAsync(identifier);

                if (user == null)
                {
                    var searchResult = await _nguoiDungService.GetAllAsync(1, 1, identifier);
                    if (searchResult.Items.Any())
                    {
                        var foundUser = searchResult.Items.First();
                        user = await _nguoiDungService.GetByIdAsync(foundUser.MSSV);
                    }
                }

                if (user == null)
                {
                    return NotFound(new { message = "User not found" });
                }

                return Ok(user);
            }
            catch (Exception ex)
            {
                return StatusCode(500, new { message = "An error occurred while finding user", error = ex.Message });
            }
        }

        [HttpGet("all")]
        [Permission(Permissions.NguoiDung.View)]
        public async Task<ActionResult<PagedResult<GetNguoiDungDTO>>> GetAllUsers(
            [FromQuery] int page = 1,
            [FromQuery] int pageSize = 10,
            [FromQuery] string? role = null)
        {
            return await SearchUsers(null, page, pageSize, role);
        }
    }
}
