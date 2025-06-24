using Microsoft.AspNetCore.Mvc;
using System;
using System.IO;
using System.Linq;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Hosting;
using System.Security.Cryptography;
namespace CKCQUIZZ.Server.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class FilesController : ControllerBase
    {
        private readonly IWebHostEnvironment _webHostEnvironment;

        public FilesController(IWebHostEnvironment webHostEnvironment)
        {
            _webHostEnvironment = webHostEnvironment;
        }
        [HttpPost("upload")]
        public async Task<IActionResult> UploadImage(IFormFile file)
        {
            try
            {
                if (file == null || file.Length == 0)
                {
                    return BadRequest(new { message = "Không có file nào được tải lên." });
                }
                // Kiểm tra kích thước file (ví dụ: giới hạn 5MB)
                if (file.Length > 5 * 1024 * 1024) // 5 MB
                {
                    return BadRequest(new { message = "Kích thước file không được vượt quá 5MB." });
                }
                var allowedExtensions = new[] { ".jpg", ".jpeg", ".png", ".gif" };
                var extension = Path.GetExtension(file.FileName).ToLowerInvariant();
                if (string.IsNullOrEmpty(extension) || !allowedExtensions.Contains(extension))
                {
                    return BadRequest(new { message = "Định dạng file không hợp lệ. Chỉ chấp nhận .jpg, .jpeg, .png, .gif." });
                }
                var uploadPath = Path.Combine(_webHostEnvironment.WebRootPath, "uploads", "questions");
                if (!Directory.Exists(uploadPath))
                {
                    Directory.CreateDirectory(uploadPath);
                }

                // Calculate file hash to check for duplicates
                string fileHash;
                using (var stream = file.OpenReadStream())
                {
                    using (var sha256 = SHA256.Create())
                    {
                        var hashBytes = await sha256.ComputeHashAsync(stream);
                        fileHash = Convert.ToHexString(hashBytes).ToLower();
                    }
                }

                // Check if file with same hash already exists
                var existingFiles = Directory.GetFiles(uploadPath, $"{fileHash}_*");
                if (existingFiles.Length > 0)
                {
                    // Return existing file URL
                    var existingFileName = Path.GetFileName(existingFiles[0]);
                    var request = HttpContext.Request;
                    var existingImageUrl = $"{request.Scheme}://{request.Host}/uploads/questions/{existingFileName}";
                    return Ok(new { url = existingImageUrl, message = "File đã tồn tại, sử dụng file có sẵn" });
                }

                // Create new file with hash prefix
                var uniqueFileName = $"{fileHash}_{Guid.NewGuid()}{Path.GetExtension(file.FileName)}";
                var filePath = Path.Combine(uploadPath, uniqueFileName);

                // Save file
                using (var stream = new FileStream(filePath, FileMode.Create))
                {
                    await file.CopyToAsync(stream);
                }

                // 3. =========== TRẢ VỀ URL CÔNG KHAI CỦA FILE ============

                // Tạo URL để frontend có thể dùng để hiển thị ảnh
                // Ví dụ: https://localhost:7254/uploads/questions/1a2b3c4d..._ten-goc.jpg
                var request = HttpContext.Request;
                var imageUrl = $"{request.Scheme}://{request.Host}/uploads/questions/{uniqueFileName}";

                // Trả về một đối tượng JSON chứa URL của ảnh, đúng định dạng mà frontend mong đợi
                return Ok(new { url = imageUrl });
            }
            catch (Exception ex)
            {
                // Ghi log lỗi ở đây nếu bạn có hệ thống log
                return StatusCode(500, new { message = $"Đã xảy ra lỗi hệ thống khi tải file: {ex.Message}" });
            }
        }
        [HttpPost("upload-avatar")]
        public async Task<IActionResult> UploadAvatar(IFormFile file)
        {
            try
            {
                if (file == null || file.Length == 0)
                {
                    return BadRequest(new { message = "Không có file nào được tải lên." });
                }

                if (file.Length > 5 * 1024 * 1024) // 5 MB
                {
                    return BadRequest(new { message = "Kích thước file không được vượt quá 5MB." });
                }

                var allowedExtensions = new[] { ".jpg", ".jpeg", ".png", ".gif" };
                var extension = Path.GetExtension(file.FileName).ToLowerInvariant();
                if (string.IsNullOrEmpty(extension) || !allowedExtensions.Contains(extension))
                {
                    return BadRequest(new { message = "Định dạng file không hợp lệ. Chỉ chấp nhận .jpg, .jpeg, .png, .gif." });
                }

                var uploadPath = Path.Combine(_webHostEnvironment.WebRootPath, "uploads", "avatars");
                if (!Directory.Exists(uploadPath))
                {
                    Directory.CreateDirectory(uploadPath);
                }

                var uniqueFileName = Guid.NewGuid().ToString() + extension;
                var filePath = Path.Combine(uploadPath, uniqueFileName);

                using (var stream = new FileStream(filePath, FileMode.Create))
                {
                    await file.CopyToAsync(stream);
                }

                var request = HttpContext.Request;
                var imageUrl = $"{request.Scheme}://{request.Host}/uploads/avatars/{uniqueFileName}";

                return Ok(new { url = imageUrl });
            }
            catch (Exception ex)
            {
                return StatusCode(500, new { message = $"Đã xảy ra lỗi hệ thống khi tải file avatar: {ex.Message}" });
            }
        }
    }
}