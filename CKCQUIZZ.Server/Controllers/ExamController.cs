using CKCQUIZZ.Server.Interfaces;
using CKCQUIZZ.Server.Viewmodels.Student;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using System.Threading.Tasks;
using System.Security.Claims;
using CKCQUIZZ.Server.Models;

namespace CKCQUIZZ.Server.Controllers
{
    public class ExamController(IDeThiService _deThiService, CkcquizzContext _context) : BaseController
    {
        private string GetCurrentUserId()
        {
            return User.FindFirstValue(ClaimTypes.NameIdentifier) ?? "Không tìm thấy người dùng";
        }
        [HttpPost("start")]
        public async Task<IActionResult> StartExam([FromBody] StartExamRequestDto request)
        {
            var studentId = GetCurrentUserId();
            if (string.IsNullOrEmpty(studentId))
            {
                return Unauthorized("Không thể xác thực người dùng.");
            }

            try
            {
                var response = await _deThiService.StartExam(request, studentId);
                return Ok(response);
            }
            catch (KeyNotFoundException ex)
            {
                return NotFound(ex.Message);
            }
            catch (InvalidOperationException ex)
            {
                return BadRequest(ex.Message);
            }
            catch (Exception ex)
            {
                return StatusCode(500, $"Lỗi server khi bắt đầu bài thi: {ex.Message}");
            }
        }

        [HttpGet("{id}")]
        public async Task<IActionResult> GetExam(int id)
        {
            var studentId = GetCurrentUserId();
            if (string.IsNullOrEmpty(studentId))
            {
                return Unauthorized("Không thể xác thực người dùng.");
            }

            var exam = await _deThiService.GetExamForStudent(id, studentId);
            if (exam == null)
            {
                return NotFound();
            }
            return Ok(exam);
        }

        [HttpPost("submit")]
        public async Task<IActionResult> SubmitExam([FromBody] SubmitExamRequestDto submission)
        {
            var studentId = GetCurrentUserId();
            if (string.IsNullOrEmpty(studentId))
            {
                return Unauthorized("Không thể xác thực người dùng.");
            }

            try
            {
                var result = await _deThiService.SubmitExam(submission, studentId);
                return Ok(result);
            }
            catch (KeyNotFoundException ex)
            {
                return NotFound(ex.Message);
            }
            catch (InvalidOperationException ex)
            {
                return BadRequest(ex.Message);
            }
            catch (Exception ex)
            {
                return StatusCode(500, $"Có lỗi xảy ra khi nộp bài: {ex.Message}");
            }
        }

        [HttpPost("update-answer")]
        public async Task<IActionResult> UpdateStudentAnswer([FromBody] UpdateAnswerRequestDto request)
        {
            var studentId = GetCurrentUserId();
            if (string.IsNullOrEmpty(studentId))
            {
                return Unauthorized("Không thể xác thực người dùng.");
            }

            try
            {
                var success = await _deThiService.UpdateStudentAnswer(request, studentId);
                if (success)
                {
                    return Ok();
                }
                else
                {
                    return BadRequest("Cập nhật câu trả lời thất bại.");
                }
            }
            catch (KeyNotFoundException ex)
            {
                return NotFound(ex.Message);
            }
            catch (Exception ex)
            {
                return StatusCode(500, $"Lỗi server khi cập nhật câu trả lời: {ex.Message}");
            }
        }

        [HttpGet("exam-result/{ketQuaId}")]
        public async Task<IActionResult> GetStudentExamResult(int ketQuaId)
        {
            var studentId = GetCurrentUserId();
            if (string.IsNullOrEmpty(studentId))
            {
                return Unauthorized("Không thể xác thực người dùng.");
            }
            var result = await _deThiService.GetStudentExamResult(ketQuaId, studentId);
            if (result == null)
                return NotFound();
            return Ok(result);
        }

        [HttpGet("saved-answers/{ketQuaId}")]
        public async Task<IActionResult> GetStudentSavedAnswers(int ketQuaId)
        {
            var studentId = GetCurrentUserId();
            if (string.IsNullOrEmpty(studentId))
            {
                return Unauthorized("Không thể xác thực người dùng.");
            }
            var result = await _deThiService.GetStudentSavedAnswers(ketQuaId, studentId);
            if (result == null)
                return NotFound("Không tìm thấy đáp án đã lưu.");
            return Ok(result);
        }

        [HttpGet("teacher-exam-result/{ketQuaId}")]
        public async Task<IActionResult> GetStudentExamResultForTeacher(int ketQuaId)
        {
            var ketQua = await _context.KetQuas.FirstOrDefaultAsync(kq => kq.Makq == ketQuaId);
            if (ketQua == null)
            {
                return NotFound("Không tìm thấy kết quả bài làm.");
            }

            var result = await _deThiService.TeacherGetStudentExamResult(ketQuaId);
            if (result == null)
                return NotFound();
            return Ok(result);
        }
    }
}