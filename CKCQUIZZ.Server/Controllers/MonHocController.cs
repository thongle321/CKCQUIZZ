using CKCQUIZZ.Server.Interfaces;
using CKCQUIZZ.Server.Mappers;
using CKCQUIZZ.Server.Models;
using CKCQUIZZ.Server.Viewmodels.MonHoc;
using FluentValidation;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using CKCQUIZZ.Server.Authorization; 

namespace CKCQUIZZ.Server.Controllers
{
    public class MonHocController(IMonHocService _monHocService) : BaseController
    {
        [HttpGet]
        [Permission(Permissions.MonHoc.View)]
        public async Task<IActionResult> GetAll([FromQuery] string? searchTerm)
        {
            var subjects = await _monHocService.GetAllAsync();

            if (!string.IsNullOrWhiteSpace(searchTerm))
            {
                subjects = subjects.Where(s =>
                    s.Mamonhoc.ToString().Contains(searchTerm, StringComparison.OrdinalIgnoreCase) ||
                    s.Tenmonhoc.Contains(searchTerm, StringComparison.OrdinalIgnoreCase)
                ).ToList();
            }

            var subjectDto = subjects.Select(s => s.ToMonHocDto());

            return Ok(subjectDto);
        }

        [HttpGet("paged")]
        [Permission(Permissions.MonHoc.View)]
        public async Task<IActionResult> GetPaged([FromQuery] int page = 1, [FromQuery] int pageSize = 6)
        {
            var query = await _monHocService.GetAllAsync();
            var total = query.Count;

            var data = query
                .Skip((page - 1) * pageSize)
                .Take(pageSize)
                .Select(s => s.ToMonHocDto())
                .ToList();

            return Ok(new
            {
                total,
                data
            });
        }



        [HttpGet("{id}")]
        [Permission(Permissions.MonHoc.View)]
        public async Task<IActionResult> GetById([FromRoute] int id)
        {
            var monHoc = await _monHocService.GetByIdAsync(id);

            if (monHoc is null)
            {
                return NotFound("Không tìm thấy môn học");
            }

            return Ok(monHoc.ToMonHocDto());
        }

        [HttpPost]
        [Permission(Permissions.MonHoc.Create)]
        public async Task<IActionResult> Create([FromBody] CreateMonHocRequestDTO createMonHocDto, IValidator<CreateMonHocRequestDTO> _validator)
        {
            var validationResult = _validator.Validate(createMonHocDto);
            if (!validationResult.IsValid)
            {
                var problemDetails = new HttpValidationProblemDetails(validationResult.ToDictionary())
                {
                    Status = StatusCodes.Status400BadRequest,
                    Title = "Lỗi xác thực dữ liệu",
                    Instance = "/api/MonHoc"
                };
                return BadRequest(problemDetails);
            }
            try
            {
                var monHocModel = createMonHocDto.ToMonHocFromCreateDto();

                var createdMonHoc = await _monHocService.CreateAsync(monHocModel);

                return CreatedAtAction(nameof(GetById), new { id = monHocModel.Mamonhoc }, monHocModel.ToMonHocDto());
            }
            catch (Exception ex)
            {

                return BadRequest(ex.Message);
            }
        }
            

        

        [HttpPut]
        [Route("{id}")]
        [Permission(Permissions.MonHoc.Update)]
        public async Task<IActionResult> Update([FromRoute] int id, [FromBody] UpdateMonHocRequestDTO updateMonHocDto, IValidator<UpdateMonHocRequestDTO> _validator)
        {
            var validationResult = _validator.Validate(updateMonHocDto);
            if (!validationResult.IsValid)
            {
                var problemDetails = new HttpValidationProblemDetails(validationResult.ToDictionary())
                {
                    Status = StatusCodes.Status400BadRequest,
                    Title = "Lỗi xác thực dữ liệu",
                    Instance = "/api/MonHoc"
                };
                return BadRequest(problemDetails);
            }
            var monHocModel = await _monHocService.UpdateAsync(id, updateMonHocDto);

            if (monHocModel is null)
            {
                return NotFound("Không tìm thấy môn học để cập nhật");
            }
            return Ok(monHocModel.ToMonHocDto());
        }

        [HttpDelete]
        [Route("{id}")]
        [Permission(Permissions.MonHoc.Delete)]
        public async Task<IActionResult> Delete([FromRoute] int id)
        {
            try
            {
                var monHocModel = await _monHocService.DeleteAsync(id);

                if (monHocModel is null)
                {
                    return NotFound("Không tìm thấy môn học để xóa");
                }
                return NoContent();
            }
            catch (InvalidOperationException ex)
            {
                return BadRequest(new { message = ex.Message });
            }
          
        }
    }

}

