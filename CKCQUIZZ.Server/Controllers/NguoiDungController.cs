using CKCQUIZZ.Server.Interfaces;
using CKCQUIZZ.Server.Models;
using CKCQUIZZ.Server.Viewmodels.NguoiDung;
using Microsoft.AspNetCore.Mvc;
using CKCQUIZZ.Server.Viewmodels;
using FluentValidation;
using Microsoft.AspNetCore.Identity;
namespace CKCQUIZZ.Server.Controllers
{
    public class NguoiDungController(INguoiDungService _nguoiDungService, UserManager<NguoiDung> _userManager) : BaseController
    {

        [HttpGet]
        public async Task<ActionResult<PagedResult<GetNguoiDungDTO>>> GetAllUsers(string? searchQuery, string? role, int page = 1, int pageSize = 10)
        {

            var users = await _nguoiDungService.GetAllAsync(page, pageSize, searchQuery, role);
            return Ok(users);
        }

        [HttpGet("{id}")]
        public async Task<ActionResult<NguoiDung>> GetUserById(string id)
        {
            var user = await _nguoiDungService.GetByIdAsync(id);
            if (user == null)
            {
                return NotFound();
            }
            return Ok(user);
        }

        [HttpPost]
        public async Task<IActionResult> CreateUser([FromBody] CreateNguoiDungRequestDTO request, IValidator<CreateNguoiDungRequestDTO> _validator)
        {
            var validationResult = await _validator.ValidateAsync(request);
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

            var user = new NguoiDung
            {
                Id = request.MSSV,
                UserName = request.UserName,
                Email = request.Email,
                Hoten = request.Hoten,
                Gioitinh = request.Gioitinh,
                Ngaysinh = request.Ngaysinh,
                PhoneNumber = request.PhoneNumber,
                Trangthai = true
            };

            var createResult = await _nguoiDungService.CreateAsync(user, request.Password);
            if (!createResult.Succeeded)
            {
                return BadRequest(createResult.Errors);
            }

            var roleResult = await _nguoiDungService.AssignRoleAsync(user, request.Role);
            if (!roleResult.Succeeded)
            {
                return BadRequest(roleResult.Errors);
            }

            return CreatedAtAction(nameof(GetUserById), new { id = user.Id }, user);
        }

        [HttpPut("{id}")]
        public async Task<IActionResult> UpdateUser(string id, [FromBody] UpdateNguoiDungRequestDTO request)
        {
            var user = await _nguoiDungService.GetByIdAsync(id);
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
            user.Gioitinh = request.Gioitinh;

            var result = await _nguoiDungService.UpdateAsync(user);
            if (!result.Succeeded)
            {
                return BadRequest(result.Errors);
            }
            var roleResult = await _nguoiDungService.SetUserRoleAsync(user, request.Role);
            if (!roleResult.Succeeded)
            {
                return BadRequest(roleResult.Errors);
            }

            return NoContent();
        }

        [HttpDelete("{id}")]
        public async Task<IActionResult> DeleteUser(string id)
        {
            var result = await _nguoiDungService.DeleteAsync(id);
            if (!result.Succeeded)
            {
                return BadRequest(result.Errors);
            }
            return NoContent();
        }

        [HttpGet("roles")]
        public async Task<List<string>> GetRole()
        {
            return await _nguoiDungService.GetAllRolesAsync();
        }

        [HttpGet("check-mssv/{mssv}")]
        public async Task<IActionResult> CheckMssv(string mssv)
        {
            var user = await _userManager.FindByIdAsync(mssv);
            if (user == null)
            {
                return NotFound();
            }
            return Ok();
        }

        [HttpGet("check-email/{email}")]
        public async Task<IActionResult> CheckEmail(string email)
        {
            var user = await _userManager.FindByEmailAsync(email);
            if (user == null)
            {
                return NotFound();
            }
            return Ok();
        }
    }

}