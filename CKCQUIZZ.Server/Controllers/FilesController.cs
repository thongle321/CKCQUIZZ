using CKCQUIZZ.Server.Interfaces;
using CKCQUIZZ.Server.Viewmodels.CauHoi;
using Microsoft.AspNetCore.Mvc;
using System;
using System.IO;
using System.Linq;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Hosting;
using CKCQUIZZ.Server.Authorization;
using System.Security.Claims;
namespace CKCQUIZZ.Server.Controllers
{
    public class FilesController(IFileService _fileService) : BaseController
    {
        private string GetCurrentUserId()
        {
            return User.FindFirstValue(ClaimTypes.NameIdentifier) ?? "Không tìm thấy người dùng";
        }
        [HttpPost("upload")]
        public async Task<IActionResult> UploadImage(IFormFile file)
        {
            try
            {
                var imageUrl = await _fileService.UploadImageAsync(file, "questions");
                return Ok(new { url = imageUrl });
            }
            catch (ArgumentException ex)
            {
                return BadRequest(new { message = ex.Message });
            }
            catch (Exception ex)
            {
                return StatusCode(500, new { message = $"Đã xảy ra lỗi hệ thống khi tải file: {ex.Message}" });
            }
        }

        [HttpPost("upload-avatar")]
        public async Task<IActionResult> UploadAvatar(IFormFile file)
        {
            try
            {
                var imageUrl = await _fileService.UploadImageAsync(file, "avatars");
                return Ok(new { url = imageUrl });
            }
            catch (ArgumentException ex)
            {
                return BadRequest(new { message = ex.Message });
            }
            catch (Exception ex)
            {
                return StatusCode(500, new { message = $"Đã xảy ra lỗi hệ thống khi tải file avatar: {ex.Message}" });
            }
        }

        [HttpPost("import-from-zip")]
        [Permission(Permissions.CauHoi.Create)]
        [RequestSizeLimit(100_000_000)]
        public async Task<IActionResult> ImportFromZip(IFormFile file, [FromQuery] int maMonHoc, [FromQuery] int maChuong, [FromQuery] int doKho)
        {

            try
            {
                var userId = GetCurrentUserId(); 
                if (string.IsNullOrEmpty(userId))
                {
                    return Unauthorized(new { message = "Người dùng chưa được xác thực." });
                }

                var result = await _fileService.ImportFromZipAsync(file, maMonHoc, maChuong, doKho, userId);
                if (result.DanhSachLoi.Any())
                {
                    return BadRequest(result);
                }
                return Ok(result);
            }
            catch (ArgumentException ex)
            {
                return BadRequest(new { message = ex.Message });
            }
            catch (Exception ex)
            {
                return StatusCode(500, new { message = $"Đã xảy ra lỗi hệ thống khi import file: {ex.Message}" });
            }
        }
    }
}