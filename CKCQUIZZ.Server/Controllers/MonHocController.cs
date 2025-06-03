using CKCQUIZZ.Server.Interfaces;
using CKCQUIZZ.Server.Models;
using CKCQUIZZ.Server.Mappers;

using Microsoft.AspNetCore.Mvc;
using CKCQUIZZ.Server.Viewmodels.Subject;
using FluentValidation;
namespace CKCQUIZZ.Server.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class MonHocController(IMonHocService _monHocService) : ControllerBase
    {
        [HttpGet]
        public async Task<IActionResult> GetAll()
        {
            var subjects = await _monHocService.GetAllAsync();
            var subjectDto = subjects.Select(s => s.ToMonHocDto());

            return Ok(subjects);
        }

        [HttpGet("{id}")]
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
            var monHocModel = createMonHocDto.ToMonHocFromCreateDto();

            await _monHocService.CreateAsync(monHocModel);

            return CreatedAtAction(nameof(GetById), new { id = monHocModel.Mamonhoc }, monHocModel.ToMonHocDto());

        }

        [HttpPut]
        [Route("{id}")]
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
        public async Task<IActionResult> Delete([FromRoute] int id)
        {
            var monHocModel = await _monHocService.DeleteAsync(id);

            if (monHocModel is null)
            {
                return NotFound("Không tìm thấy môn học để xóa");
            }
            return NoContent();
        }
    }

}

