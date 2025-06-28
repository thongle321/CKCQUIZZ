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
            return User.FindFirstValue(ClaimTypes.NameIdentifier);
        }

        private string GetCurrentUserRole()
        {
            return User.FindFirstValue(ClaimTypes.Role) ?? "Unknown";
        }
        [HttpGet]
        public async Task<IActionResult> GetAll([FromQuery] bool? hienthi)
        {
            var userId = GetCurrentUserId();
            var userRole = GetCurrentUserRole();
            var lops = await _lopService.GetAllAsync(userId, hienthi, userRole);

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
            var currentUserId = GetCurrentUserId();
            var currentUserRole = GetCurrentUserRole();

            string giangvienId;
            if (currentUserRole.ToLower() == "admin" && !string.IsNullOrEmpty(createLopDto.GiangvienId))
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
        public async Task<IActionResult> Update([FromRoute] int id, [FromBody] UpdateLopRequestDTO updateLopDto)
        {
            var currentUserRole = GetCurrentUserRole();

            if (currentUserRole.ToLower() != "admin")
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

        // ===== JOIN REQUEST ENDPOINTS =====

        /// <summary>
        /// Student joins class by invite code
        /// </summary>
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

        /// <summary>
        /// Get count of pending join requests for a class
        /// </summary>
        [HttpGet("{id:int}/pending-requests/count")]
        public async Task<IActionResult> GetPendingRequestCount(int id)
        {
            var count = await _lopService.GetPendingRequestCountAsync(id);
            return Ok(new PendingRequestCountDTO { Malop = id, PendingCount = count });
        }

        /// <summary>
        /// Get list of pending students for a class
        /// </summary>
        [HttpGet("{id:int}/pending-requests")]
        public async Task<IActionResult> GetPendingStudents(int id)
        {
            var pendingStudents = await _lopService.GetPendingStudentsAsync(id);
            return Ok(pendingStudents);
        }

        /// <summary>
        /// Approve a pending join request
        /// </summary>
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

        /// <summary>
        /// Reject a pending join request
        /// </summary>
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
    }
}