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
        /// <summary>
        /// Search users by ID, email, or name with pagination
        /// </summary>
        /// <param name="query">Search query (ID, email, or name)</param>
        /// <param name="page">Page number (default: 1)</param>
        /// <param name="pageSize">Page size (default: 10, max: 100)</param>
        /// <param name="role">Filter by role (optional)</param>
        /// <returns>Paginated list of users</returns>
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
                // Use existing service method which handles search properly
                var users = await _nguoiDungService.GetAllAsync(page, pageSize, query, role);
                return Ok(users);
            }
            catch (Exception ex)
            {
                return StatusCode(500, new { message = "An error occurred while searching users", error = ex.Message });
            }
        }

        /// <summary>
        /// Get user by exact ID or email
        /// </summary>
        /// <param name="identifier">User ID or email</param>
        /// <returns>User details</returns>
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

                // Try to find by ID first, then by email
                var user = await _nguoiDungService.GetByIdAsync(identifier);

                if (user == null)
                {
                    // Search by email using the search functionality
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

        /// <summary>
        /// Get all users with optional filters (for admin)
        /// </summary>
        /// <param name="page">Page number</param>
        /// <param name="pageSize">Page size</param>
        /// <param name="role">Filter by role</param>
        /// <returns>Paginated list of all users</returns>
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
