using CKCQUIZZ.Server.Interfaces;
using CKCQUIZZ.Server.Viewmodels.Student;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using System.Threading.Tasks;
using System.Security.Claims;

namespace CKCQUIZZ.Server.Controllers
{
    public class StudentExamController(IDeThiService _deThiService) : BaseController
    {
        [HttpGet("{id}")]
        public async Task<IActionResult> GetExam(int id)
        {
            var exam = await _deThiService.GetExamForStudent(id);
            if (exam == null)
            {
                return NotFound();
            }
            return Ok(exam);
        }

        [HttpPost("submit")]
        public async Task<IActionResult> SubmitExam([FromBody] SubmitExamRequestDto submission)
        {
            var studentId = User.FindFirstValue(ClaimTypes.NameIdentifier);
            if (string.IsNullOrEmpty(studentId))
            {
                return Unauthorized("Không thể xác thực người dùng.");
            }

            try
            {
                var result = await _deThiService.SubmitExam(submission, studentId);
                return Ok(result);
            }
            catch (Exception ex)
            {
                // Ghi log lỗi ở đây (nếu cần)
                return BadRequest($"Có lỗi xảy ra khi nộp bài: {ex.Message}");
            }
        }
    }
} 