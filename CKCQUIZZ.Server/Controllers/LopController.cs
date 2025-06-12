using System.Security.Claims;
using CKCQUIZZ.Server.Interfaces;
using CKCQUIZZ.Server.Mappers;
using CKCQUIZZ.Server.Viewmodels.Lop;
using Microsoft.AspNetCore.Mvc;

namespace CKCQUIZZ.Server.Controllers
{
    public class LopController(ILopService _lopService) : BaseController
    {
        private string GetCurrentUserId()
        {
            return User.FindFirstValue(ClaimTypes.NameIdentifier) ?? throw new Exception("Người dùng không xác thực");

        }
        [HttpGet]
        public async Task<IActionResult> GetAll([FromQuery] bool? hienthi)
        {
            var giangvienId = GetCurrentUserId();
            var lops = await _lopService.GetAllAsync(giangvienId, hienthi);

            var lopDtos = lops.Select(l => l.ToLopDto());
            return Ok(lopDtos);
        }

        [HttpGet("{id}")]
        public async Task<IActionResult> GetById([FromRoute] int id)
        {
            var lop = await _lopService.GetByIdAsync(id);

            if (lop is null)
            {
                return NotFound("Không tìm thấy lớp học");
            }

            return Ok(lop.ToLopDto());
        }

        [HttpPost]
        public async Task<IActionResult> Create([FromBody] CreateLopRequestDTO createLopDto)
        {
            var giangvienId = GetCurrentUserId();
            var lopModel = createLopDto.ToLopFromCreateDto();

            await _lopService.CreateAsync(lopModel, createLopDto.Mamonhoc, giangvienId);

            return CreatedAtAction(nameof(GetById), new { id = lopModel.Malop }, lopModel.ToLopDto());

        }

        [HttpPut]
        [Route("{id}")]
        public async Task<IActionResult> Update([FromRoute] int id, [FromBody] UpdateLopRequestDTO updateLopDto)
        {
            var lopModel = await _lopService.UpdateAsync(id, updateLopDto);

            if (lopModel is null)
            {
                return NotFound("Không tìm thấy lớp học để cập nhật");
            }
            return Ok(lopModel.ToLopDto());
        }

        [HttpDelete]
        [Route("{id}")]
        public async Task<IActionResult> Delete([FromRoute] int id)
        {
            var lopModel = await _lopService.DeleteAsync(id);

            if (lopModel is null)
            {
                return NotFound("Không tìm thấy lớp học để xóa");
            }
            return NoContent();
        }
        [HttpPut("{id:int}/toggle-status")]
        public async Task<IActionResult> ToggleStatus(int id, [FromQuery] bool hienthi)
        {
            var lop = await _lopService.ToggleStatusAsync(id, hienthi);
            if (lop == null) return NotFound();
            return Ok(new { message = "Cập nhật trạng thái thành công" });
        }   

        [HttpPut("{id:int}/invite-code")]
        public async Task<IActionResult> RefreshInviteCode(int id)
        {
            var newCode = await _lopService.RefreshInviteCodeAsync(id);
            if (newCode == null) return NotFound();
            return Ok(new { inviteCode = newCode });
        }

        [HttpGet("{id:int}/students")]
        public async Task<IActionResult> GetStudentsInClass(int id)
        {
            var students = await _lopService.GetStudentsInClassAsync(id);
            var studentDtos = students.Select(s => s.ToSinhVienDto());
            return Ok(studentDtos);
        }

        [HttpPost("{id:int}/students")]
        public async Task<IActionResult> AddStudentToClass(int id, [FromBody] AddSinhVienRequestDTO request)
        {
            var result = await _lopService.AddStudentToClassAsync(id, request.ManguoidungId);
            if (result == null)
            {
                return BadRequest("Không thể thêm sinh viên. Sinh viên không tồn tại hoặc đã ở trong lớp.");
            }
            return Ok(new { message = "Thêm sinh viên vào lớp thành công." });
        }

        [HttpDelete("{id:int}/students/{studentId}")]
        public async Task<IActionResult> KickStudent(int id, string studentId)
        {
            var success = await _lopService.KickStudentFromClassAsync(id, studentId);
            if (!success)
            {
                return NotFound("Không tìm thấy sinh viên trong lớp này để xóa.");
            }
            return NoContent();
        }
    }
}