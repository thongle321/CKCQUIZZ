using CKCQUIZZ.Server.Interfaces;
using CKCQUIZZ.Server.Models;
using CKCQUIZZ.Server.Viewmodels.NguoiDung;
using Microsoft.AspNetCore.Mvc;
using CKCQUIZZ.Server.Viewmodels;
using FluentValidation;
using Microsoft.AspNetCore.Identity;
using CKCQUIZZ.Server.Authorization;
using Microsoft.EntityFrameworkCore;

namespace CKCQUIZZ.Server.Controllers
{
    public class NguoiDungController(INguoiDungService _nguoiDungService, UserManager<NguoiDung> _userManager) : BaseController
    {

        [HttpGet]
        [Permission(Permissions.NguoiDung.View)]
        public async Task<ActionResult<PagedResult<GetNguoiDungDTO>>> GetAllUsers(string? searchQuery, string? role, int page = 1, int pageSize = 10)
        {

            var users = await _nguoiDungService.GetAllAsync(page, pageSize, searchQuery, role);
            return Ok(users);
        }

        [HttpGet("{id}")]
        [Permission(Permissions.NguoiDung.View)]
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
        [Permission(Permissions.NguoiDung.Create)]
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
                UserName = request.MSSV,
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
        [Permission(Permissions.NguoiDung.Update)]
        public async Task<IActionResult> UpdateUser(string id, [FromBody] UpdateNguoiDungRequestDTO request, IValidator<UpdateNguoiDungRequestDTO> _validator)
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
            var user = await _nguoiDungService.GetByIdAsync(id);
            if (user == null)
            {
                return NotFound();
            }

            var existingUserWithPhone = await _userManager.Users.FirstOrDefaultAsync(u => u.PhoneNumber == request.PhoneNumber && u.Id != id);
            if (existingUserWithPhone != null)
            {
                return BadRequest(new { message = "Số điện thoại này đã được sử dụng bởi người dùng khác." });
            }

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
        [Permission(Permissions.NguoiDung.Delete)]
        public async Task<IActionResult> DeleteUser(string id)
        {
            var result = await _nguoiDungService.DeleteAsync(id);
            if (!result.Succeeded)
            {
                return BadRequest(result.Errors);
            }
            return NoContent();
        }

        [HttpPut("{id}/soft-delete")]
        [Permission(Permissions.NguoiDung.Delete)]
        public async Task<IActionResult> ToggleUserStatus(string id, [FromQuery] bool hienthi)
        {
            var result = await _nguoiDungService.SoftDeleteAsync(id, hienthi);
            if (!result.Succeeded)
            {
                return BadRequest(result.Errors);
            }
            return Ok(new { message = "Xóa người dùng thành công." });
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

        [HttpGet("check-phone/{phoneNumber}")]
        public async Task<IActionResult> CheckPhoneNumber(string phoneNumber)
        {
            var user = await _userManager.Users.FirstOrDefaultAsync(u => u.PhoneNumber == phoneNumber);
            if (user == null)
            {
                return NotFound();
            }
            return Ok();
        }

        [HttpGet("check-phone/{phoneNumber}/exclude/{userId}")]
        public async Task<IActionResult> CheckPhoneNumberForUpdate(string phoneNumber, string userId)
        {
            var user = await _userManager.Users.FirstOrDefaultAsync(u => u.PhoneNumber == phoneNumber && u.Id != userId);
            if (user == null)
            {
                return NotFound();
            }
            return Ok();
        }


    }

}