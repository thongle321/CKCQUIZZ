using CKCQUIZZ.Server.Interfaces;
using CKCQUIZZ.Server.Viewmodels.KetQua;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using System.Security.Claims;

namespace CKCQUIZZ.Server.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    [Authorize]
    public class KetQuaController : ControllerBase
    {
        private readonly IKetQuaService _ketQuaService;

        public KetQuaController(IKetQuaService ketQuaService)
        {
            _ketQuaService = ketQuaService;
        }

        private string GetCurrentUserId()
        {
            return User.FindFirstValue(ClaimTypes.NameIdentifier)
                ?? throw new UnauthorizedAccessException("Không thể xác định người dùng. Vui lòng đăng nhập lại.");
        }

        /// <summary>
        /// Submit bài thi của sinh viên
        /// </summary>
        [HttpPost("submit")]
        public async Task<IActionResult> SubmitExam([FromBody] SubmitExamRequestDto request)
        {
            try
            {
                if (!ModelState.IsValid)
                {
                    return BadRequest(ModelState);
                }

                var studentId = GetCurrentUserId();
                
                // Validate student ID matches request
                if (request.Manguoidung != studentId)
                {
                    return Forbid("Không thể nộp bài cho người dùng khác");
                }

                var result = await _ketQuaService.SubmitExamAsync(request);
                
                if (result == null)
                {
                    return BadRequest("Không thể nộp bài thi. Vui lòng thử lại.");
                }

                return Ok(result);
            }
            catch (ArgumentException ex)
            {
                return BadRequest(ex.Message);
            }
            catch (InvalidOperationException ex)
            {
                return Conflict(ex.Message);
            }
            catch (Exception ex)
            {
                return StatusCode(500, $"Lỗi server: {ex.Message}");
            }
        }

        /// <summary>
        /// Lấy kết quả thi của sinh viên
        /// </summary>
        [HttpGet("my-results")]
        public async Task<IActionResult> GetMyResults()
        {
            try
            {
                var studentId = GetCurrentUserId();
                var results = await _ketQuaService.GetResultsByStudentAsync(studentId);
                return Ok(results);
            }
            catch (Exception ex)
            {
                return StatusCode(500, $"Lỗi server: {ex.Message}");
            }
        }

        /// <summary>
        /// Lấy chi tiết kết quả thi
        /// </summary>
        [HttpGet("{resultId}/detail")]
        public async Task<IActionResult> GetResultDetail(int resultId)
        {
            try
            {
                var studentId = GetCurrentUserId();
                var result = await _ketQuaService.GetResultDetailAsync(resultId, studentId);
                
                if (result == null)
                {
                    return NotFound("Không tìm thấy kết quả thi");
                }

                return Ok(result);
            }
            catch (UnauthorizedAccessException)
            {
                return Forbid("Không có quyền xem kết quả này");
            }
            catch (Exception ex)
            {
                return StatusCode(500, $"Lỗi server: {ex.Message}");
            }
        }

        /// <summary>
        /// Lấy kết quả thi theo đề thi (cho giáo viên)
        /// </summary>
        [HttpGet("exam/{examId}")]
        public async Task<IActionResult> GetResultsByExam(int examId)
        {
            try
            {
                var teacherId = GetCurrentUserId();
                var results = await _ketQuaService.GetResultsByExamAsync(examId, teacherId);
                return Ok(results);
            }
            catch (UnauthorizedAccessException ex)
            {
                return Forbid(ex.Message);
            }
            catch (Exception ex)
            {
                return StatusCode(500, $"Lỗi server: {ex.Message}");
            }
        }

        /// <summary>
        /// Lấy thống kê kết quả thi
        /// </summary>
        [HttpGet("exam/{examId}/statistics")]
        public async Task<IActionResult> GetExamStatistics(int examId)
        {
            try
            {
                var teacherId = GetCurrentUserId();
                var statistics = await _ketQuaService.GetExamStatisticsAsync(examId, teacherId);
                return Ok(statistics);
            }
            catch (UnauthorizedAccessException ex)
            {
                return Forbid(ex.Message);
            }
            catch (Exception ex)
            {
                return StatusCode(500, $"Lỗi server: {ex.Message}");
            }
        }
    }
}
