using CKCQUIZZ.Server.Interfaces;
using CKCQUIZZ.Server.Viewmodels.PhanCong;
using Microsoft.AspNetCore.Mvc;
using System.Collections.Generic;
using System.Security.Claims;
using System.Threading.Tasks;
using CKCQUIZZ.Server.Authorization; 
namespace CKCQUIZZ.Server.Controllers
{
    public class PhanCongController(IPhanCongService _phanCongService) : BaseController
    {
        [HttpGet]
        [Permission(Permissions.PhanCong.View)]
        public async Task<IActionResult> GetAllAssignments()
        {
            var assignments = await _phanCongService.GetAllAsync();
            return Ok(assignments);
        }

        [HttpGet("lecturers")]
        public async Task<IActionResult> GetGiangVien()
        {
            var giangVien = await _phanCongService.GetGiangVienAsync();
            return Ok(giangVien);
        }

        [HttpPost]
        [Permission(Permissions.PhanCong.Create)]
        public async Task<IActionResult> AddAssignment([FromBody] AddPhanCongRequestDTO request)
        {
            var addedSubjectIds = await _phanCongService.AddAssignmentAsync(request.GiangVienId, request.ListMaMonHoc);

            if (addedSubjectIds.Any())
            {
                var allRequested = request.ListMaMonHoc.Count == addedSubjectIds.Count;
                if (allRequested)
                {
                    return Ok(new { message = "Phân công thành công", addedSubjects = addedSubjectIds });
                }
                else
                {
                    var failedSubjects = request.ListMaMonHoc.Except(addedSubjectIds).ToList();
                    return BadRequest(new { message = "Một số môn học đã được phân công trước đó.", addedSubjects = addedSubjectIds, failedSubjects = failedSubjects });
                }
            }
            else
            {
                return BadRequest(new { message = "Tất cả các môn học đã được phân công trước đó hoặc không có môn học nào được cung cấp." });
            }
        }

        [HttpDelete("{maMonHoc}/{maNguoiDung}")]
        [Permission(Permissions.PhanCong.Delete)]
        public async Task<IActionResult> DeleteAssignment(int maMonHoc, string maNguoiDung)
        {
            var result = await _phanCongService.DeleteAssignmentAsync(maMonHoc, maNguoiDung);
            if (result)
            {
                return Ok(new { message = "Xóa phân công thành công" });
            }
            return NotFound(new { message = "Không tìm thấy phân công để xóa" });
        }

        [HttpDelete("delete-by-user/{maNguoiDung}")]
        [Permission(Permissions.PhanCong.Delete)]
        public async Task<IActionResult> DeleteAllAssignmentsByUser(string maNguoiDung)
        {
            var result = await _phanCongService.DeleteAllAssignmentsByUserAsync(maNguoiDung);
            if (result)
            {
                return Ok(new { message = "Xóa tất cả phân công của người dùng thành công" });
            }
            return NotFound(new { message = "Không tìm thấy phân công nào cho người dùng này" });
        }

        [HttpGet("by-user/{maNguoiDung}")]
        public async Task<IActionResult> GetAssignmentByUser(string maNguoiDung)
        {
            var assignments = await _phanCongService.GetAssignmentByUserAsync(maNguoiDung);
            return Ok(assignments);
        }
        [HttpGet("my-assignments")]
        public async Task<IActionResult> GetMyassignments()
        {
            var userId = User.FindFirstValue(ClaimTypes.NameIdentifier);
            if (string.IsNullOrEmpty(userId))
            {
                return Unauthorized("Không tìm thấy thông tin người dùng trong token.");
            }
            var assignments = await _phanCongService.GetAssignmentByUserAsync(userId);

            return Ok(assignments);
        }

        [HttpGet("assigned-subjects")]
        public async Task<IActionResult> GetAssignedSubjects()
        {
            var userId = User.FindFirstValue(ClaimTypes.NameIdentifier);
            if (string.IsNullOrEmpty(userId))
            {
                return Unauthorized("Không tìm thấy thông tin người dùng trong token.");
            }
            var subjects = await _phanCongService.GetAssignedSubjectsAsync(userId);

            return Ok(subjects);
        }
    }


}