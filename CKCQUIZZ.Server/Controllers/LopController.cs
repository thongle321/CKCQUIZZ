using System.Security.Claims;
using CKCQUIZZ.Server.Interfaces;
using CKCQUIZZ.Server.Mappers;
using CKCQUIZZ.Server.Viewmodels.Lop;
using Microsoft.AspNetCore.Mvc;
using CKCQUIZZ.Server.Authorization;

namespace CKCQUIZZ.Server.Controllers
{
    public class LopController(ILopService _lopService) : BaseController
    {
        private string GetCurrentUserId()
        {
            return User.FindFirstValue(ClaimTypes.NameIdentifier) ?? "Không tìm thấy người dùng";
        }

        private string GetCurrentUserRole()
        {
            return User.FindFirstValue(ClaimTypes.Role) ?? "Unknown";
        }
        [HttpGet]
        [Permission(Permissions.HocPhan.View)]
        public async Task<IActionResult> GetAll([FromQuery] bool? hienthi, [FromQuery] string? searchQuery)
        {
            var userId = GetCurrentUserId();
            var userRole = GetCurrentUserRole();
            var lops = await _lopService.GetAllAsync(userId, hienthi, userRole, searchQuery);

            var lopDtos = lops.Select(l => l.ToLopDto());
            return Ok(lopDtos);
        }

        [HttpGet("{id}")]
        [Permission(Permissions.HocPhan.View)]
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
        [Permission(Permissions.HocPhan.Create)]
        public async Task<IActionResult> Create([FromBody] CreateLopRequestDTO createLopDto)
        {
            var currentUserId = GetCurrentUserId();
            var currentUserRole = GetCurrentUserRole();

            string giangvienId;
            if (currentUserRole.Equals("admin", StringComparison.CurrentCultureIgnoreCase) && !string.IsNullOrEmpty(createLopDto.GiangvienId))
            {
                giangvienId = createLopDto.GiangvienId;
            }
            else
            {
                giangvienId = currentUserId;
            }

            var lopModel = createLopDto.ToLopFromCreateDto();

            await _lopService.CreateAsync(lopModel, createLopDto.Mamonhoc, giangvienId);

            return CreatedAtAction(nameof(GetById), new { id = lopModel.Malop }, lopModel.ToLopDto());

        }

        [HttpPut]
        [Route("{id}")]
        [Permission(Permissions.HocPhan.Update)]
        public async Task<IActionResult> Update([FromRoute] int id, [FromBody] UpdateLopRequestDTO updateLopDto)
        {
            var currentUserRole = GetCurrentUserRole();

            if (!currentUserRole.Equals("admin", StringComparison.CurrentCultureIgnoreCase))
            {
                updateLopDto.GiangvienId = null;
            }

            var lopModel = await _lopService.UpdateAsync(id, updateLopDto);

            if (lopModel is null)
            {
                return NotFound("Không tìm thấy lớp học để cập nhật");
            }
            return Ok(lopModel.ToLopDto());
        }

        [HttpDelete]
        [Route("{id}")]
        [Permission(Permissions.HocPhan.Delete)]
        public async Task<IActionResult> Delete([FromRoute] int id)
        {
            var lopModel = await _lopService.DeleteAsync(id);

            if (lopModel is null)
            {
                return NotFound("Không tìm thấy lớp học để xóa");
            }
            return NoContent();
        }
        [HttpPut("{id}/toggle-status")]
        public async Task<IActionResult> ToggleStatus(int id, [FromQuery] bool hienthi)
        {
            var lop = await _lopService.ToggleStatusAsync(id, hienthi);
            if (lop == null) return NotFound();
            return Ok(new { message = "Cập nhật trạng thái thành công" });
        }

        [HttpPut("{id}/soft-delete")]
        public async Task<IActionResult> SoftDelete(int id)
        {
            var lop = await _lopService.SoftDeleteAsync(id);
            if (lop == null) return NotFound();
            return Ok(new { message = "Xóa lớp thành công" });
        }

        [HttpPut("{id:int}/invite-code")]
        public async Task<IActionResult> RefreshInviteCode(int id)
        {
            var newCode = await _lopService.RefreshInviteCodeAsync(id);
            if (newCode == null) return NotFound();
            return Ok(new { inviteCode = newCode });
        }

        [HttpGet("{id:int}/students")]
        public async Task<IActionResult> GetStudentsInClass(int id, string? searchQuery, int page = 1, int pageSize = 10)
        {
            var students = await _lopService.GetStudentsInClassAsync(id, page, pageSize, searchQuery);
            return Ok(students);
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

        [HttpGet("subjects-with-groups")]
        public async Task<IActionResult> GetSubjectsWithGroups([FromQuery] bool? hienthi)
        {
            var giangvienId = GetCurrentUserId();
            var result = await _lopService.GetSubjectsAndGroupsForTeacherAsync(giangvienId, hienthi);
            return Ok(result);
        }

        [HttpGet("subjects-with-groups-admin")]
        public async Task<IActionResult> GetSubjectsWithGroupsAdmin([FromQuery] bool? hienthi)
        {
            var result = await _lopService.GetSubjectsAndGroupsAsync(hienthi);
            return Ok(result);
        }

        [HttpPost("join-by-code")]
        public async Task<IActionResult> JoinClassByInviteCode([FromBody] JoinClassRequestDTO request)
        {
            var studentId = GetCurrentUserId();
            var result = await _lopService.JoinClassByInviteCodeAsync(request.InviteCode, studentId);

            if (result == null)
            {
                return BadRequest("Không thể tham gia lớp. Mã mời không hợp lệ hoặc bạn đã ở trong lớp này.");
            }

            return Ok(new { message = "Yêu cầu tham gia lớp đã được gửi. Chờ giáo viên duyệt." });
        }

        [HttpGet("{id:int}/pending-requests/count")]
        public async Task<IActionResult> GetPendingRequestCount(int id)
        {
            var count = await _lopService.GetPendingRequestCountAsync(id);
            return Ok(new PendingRequestCountDTO { Malop = id, PendingCount = count });
        }

        [HttpGet("{id:int}/pending-requests")]
        public async Task<IActionResult> GetPendingStudents(int id)
        {
            var pendingStudents = await _lopService.GetPendingStudentsAsync(id);
            return Ok(pendingStudents);
        }


        [HttpPut("{id:int}/approve/{studentId}")]
        public async Task<IActionResult> ApproveJoinRequest(int id, string studentId)
        {
            var success = await _lopService.ApproveJoinRequestAsync(id, studentId);

            if (!success)
            {
                return NotFound("Không tìm thấy yêu cầu tham gia để duyệt.");
            }

            return Ok(new { message = "Đã duyệt yêu cầu tham gia lớp." });
        }


        [HttpDelete("{id:int}/reject/{studentId}")]
        public async Task<IActionResult> RejectJoinRequest(int id, string studentId)
        {
            var success = await _lopService.RejectJoinRequestAsync(id, studentId);

            if (!success)
            {
                return NotFound("Không tìm thấy yêu cầu tham gia để từ chối.");
            }

            return Ok(new { message = "Đã từ chối yêu cầu tham gia lớp." });
        }

        [HttpGet("{id:int}/teachers")]
        public async Task<IActionResult> GetTeachersInClass(int id)
        {
            var teachers = await _lopService.GetTeachersInClassAsync(id);
            if (teachers == null)
            {
                return NotFound("Không tìm thấy giáo viên trong lớp này.");
            }
            return Ok(teachers);
        }

        [HttpGet("{id:int}/export-scoreboard")]
        public async Task<IActionResult> ExportScoreboard(int id)
        {
            var pdfBytes = await _lopService.ExportScoreboardPdfAsync(id);
            if (pdfBytes == null)
            {
                return NotFound("Không tìm thấy lớp học hoặc không có dữ liệu bảng điểm.");
            }

            return File(pdfBytes, "application/pdf", $"BangDiemLop_{id}.pdf");
        }

        [HttpGet("{id:int}/export-student")]
        public async Task<IActionResult> ExportStudentExcel(int id)
        {
            var excel = await _lopService.ExportStudentsToExcelAsync(id);
            if (excel == null)
            {
                return NotFound("Không tìm thấy lớp học hoặc không có dữ liệu.");
            }

            return File(excel, "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet", $"DanhSachLop_{id}.xlsx");
        }
    }
}