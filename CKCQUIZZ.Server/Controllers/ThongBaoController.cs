using CKCQUIZZ.Server.Interfaces;
using CKCQUIZZ.Server.Mappers;
using CKCQUIZZ.Server.Viewmodels.ThongBao;
using Microsoft.AspNetCore.Mvc;
using FluentValidation;
using System.Security.Claims;
using CKCQUIZZ.Server.Authorization; 

namespace CKCQUIZZ.Server.Controllers
{

    public class ThongBaoController(IThongBaoService _thongBaoService) : BaseController
    {
        private string GetCurrentUserId()
        {
            return User.FindFirstValue(ClaimTypes.NameIdentifier) ?? throw new Exception("Không thể xác thực người dùng từ token.");
        }

        [HttpGet("{id}")]
        [Permission(Permissions.ThongBao.View)]
        public async Task<IActionResult> GetById([FromRoute] int id)
        {
            var thongBao = await _thongBaoService.GetByIdAsync(id);

            if (thongBao is null)
            {
                return NotFound("Không tìm thấy thông báo");
            }

            return Ok(thongBao.ToThongBaoDto());
        }

        [HttpGet("byGroup/{groupId}")]
        [Permission(Permissions.ThongBao.View)]
        public async Task<IActionResult> GetThongBaoByLopIdAsync([FromRoute] int groupId)
        {
            var announcements = await _thongBaoService.GetThongBaoByLopIdAsync(groupId);
            return Ok(announcements);
        }

        [HttpPost]
        [Permission(Permissions.ThongBao.Create)]
        public async Task<IActionResult> CreateAsync([FromBody] CreateThongBaoRequestDTO createThongBaoDto, IValidator<CreateThongBaoRequestDTO> validator)
        {
            var validationResult = validator.Validate(createThongBaoDto);
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
            try
            {
                var giangvienId = GetCurrentUserId();

                var thongBaoModel = createThongBaoDto.ToThongBaoFromCreateDto();


                var createdThongBao = await _thongBaoService.CreateAsync(thongBaoModel, createThongBaoDto.NhomIds, giangvienId);

                return CreatedAtAction(nameof(GetById), new { id = createdThongBao.Matb }, createdThongBao.ToThongBaoDto());
            }
            catch (InvalidOperationException ex)
            {
                return BadRequest();
            }
            catch (Exception ex)
            {

                return StatusCode(500, new { message = "Đã xảy ra lỗi hệ thống. Vui lòng thử lại sau.", details = ex.Message });
            }
        }


        [HttpPut("{id}")]
        [Permission(Permissions.ThongBao.Update)]
        public async Task<IActionResult> UpdateAsync([FromRoute] int id, [FromBody] UpdateThongBaoRequestDTO updateThongBaoDto, IValidator<UpdateThongBaoRequestDTO> validator)
        {
            var validationResult = validator.Validate(updateThongBaoDto);
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
            var updatedThongBao = await _thongBaoService.UpdateAsync(id, updateThongBaoDto, updateThongBaoDto.NhomIds);

            if (updatedThongBao is null)
            {
                return NotFound("Không tìm thấy thông báo để cập nhật");
            }
            return Ok(updatedThongBao.ToThongBaoDto());
        }

        [HttpGet("me")]
        [Permission(Permissions.ThongBao.View)]
        public async Task<IActionResult> GetAllThongBaoNguoiDungAsync([FromQuery] int page = 1, [FromQuery] int pageSize = 10, [FromQuery] string? search = null)
        {
            var giangvienId = GetCurrentUserId();

            var pagedResult = await _thongBaoService.GetAllThongBaoNguoiDungAsync(giangvienId, page, pageSize, search);
            return Ok(pagedResult);
        }

        [HttpGet]
        [Permission(Permissions.ThongBao.View)] 
        public async Task<IActionResult> GetAllThongBaoAsync([FromQuery] int page = 1, [FromQuery] int pageSize = 10, [FromQuery] string? search = null)
        {
            var pagedResult = await _thongBaoService.GetAllThongBaoAsync(page, pageSize, search);
            return Ok(pagedResult);
        }

        [HttpGet("detail/{id}")]
        [Permission(Permissions.ThongBao.View)]
        public async Task<IActionResult> GetDetailForUpdate([FromRoute] int id)
        {
            var thongBaoDetail = await _thongBaoService.GetChiTietThongBaoAsync(id);

            if (thongBaoDetail is null)
            {
                return NotFound("Không tìm thấy chi tiết thông báo");
            }

            return Ok(thongBaoDetail);
        }
        [HttpGet("notifications/{userId}")]
        [Permission(Permissions.ThongBao.View)]
        public async Task<IActionResult> GetTinNhanChoNguoiDungAsync([FromRoute] string userId)
        {
            var notifications = await _thongBaoService.GetTinNhanChoNguoiDungAsync(userId);
            return Ok(notifications);
        }

        [HttpDelete("{id}")]
        [Permission(Permissions.ThongBao.Delete)]
        public async Task<IActionResult> DeleteAsync([FromRoute] int id)
        {
            var deleted = await _thongBaoService.DeleteAsync(id);

            if (deleted is null)
            {
                return NotFound("Không tìm thấy thông báo để xóa");
            }
            return NoContent();
        }
    }

}
