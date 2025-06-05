using CKCQUIZZ.Server.Interfaces;
using CKCQUIZZ.Server.Models;
using CKCQUIZZ.Server.Viewmodels.User;
using Microsoft.AspNetCore.Mvc;
using System.Collections.Generic;
using System.Threading.Tasks;

namespace CKCQUIZZ.Server.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class UserController(IUserService _userService) : ControllerBase
    {

        [HttpGet]
        public async Task<ActionResult<IEnumerable<NguoiDung>>> GetAllUsers()
        {
            var users = await _userService.GetAllAsync();
            return Ok(users);
        }

        [HttpGet("{id}")]
        public async Task<ActionResult<NguoiDung>> GetUserById(string id)
        {
            var user = await _userService.GetByIdAsync(id);
            if (user == null)
            {
                return NotFound();
            }
            return Ok(user);
        }

        [HttpPost]
        public async Task<IActionResult> CreateUser([FromBody] CreateUserRequestDTO request)
        {
            var user = new NguoiDung
            {
                Id = request.MSSV,
                UserName = request.UserName,
                Email = request.Email,
                Hoten = request.FullName,
                Ngaysinh = request.Dob,
                PhoneNumber = request.PhoneNumber,
                Trangthai = true
            };

            var createResult = await _userService.CreateAsync(user, request.Password);
            if (!createResult.Succeeded)
            {
                return BadRequest(createResult.Errors);
            }

            var roleResult = await _userService.AssignRoleAsync(user, request.Role);
            if (!roleResult.Succeeded)
            {
                return BadRequest(roleResult.Errors);
            }

            return CreatedAtAction(nameof(GetUserById), new { id = user.Id }, user);
        }

        [HttpPut("{id}")]
        public async Task<IActionResult> UpdateUser(string id, [FromBody] UpdateUserRequestDTO request)
        {
            var user = await _userService.GetByIdAsync(id);
            if (user == null)
            {
                return NotFound();
            }

            user.UserName = request.UserName;
            user.Email = request.Email;
            user.Hoten = request.FullName;
            user.Ngaysinh = request.Dob;
            user.PhoneNumber = request.PhoneNumber;
            user.Trangthai = request.Status;

            var result = await _userService.UpdateAsync(user);
            if (!result.Succeeded)
            {
                return BadRequest(result.Errors);
            }
            var roleResult = await _userService.SetUserRoleAsync(user, request.Role);
            if (!roleResult.Succeeded)
            {
                return BadRequest(roleResult.Errors);
            }

            return NoContent();
        }

        [HttpDelete("{id}")]
        public async Task<IActionResult> DeleteUser(string id)
        {
            var result = await _userService.DeleteAsync(id);
            if (!result.Succeeded)
            {
                return BadRequest(result.Errors);
            }
            return NoContent();
        }

        [HttpGet("roles")]
        public async Task<List<string>> GetRole()
        {
            return await _userService.GetAllRolesAsync();
        }
    }

}