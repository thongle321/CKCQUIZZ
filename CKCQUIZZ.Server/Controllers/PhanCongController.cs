using CKCQUIZZ.Server.Interfaces;
using CKCQUIZZ.Server.Viewmodels.PhanCong;
using Microsoft.AspNetCore.Mvc;
using System.Collections.Generic;
using System.Threading.Tasks;

namespace CKCQUIZZ.Server.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class PhanCongController : BaseController
    {
        private readonly IPhanCongService _phanCongService;

        public PhanCongController(IPhanCongService phanCongService)
        {
            _phanCongService = phanCongService;
        }

        [HttpGet]
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
        public async Task<IActionResult> AddAssignment([FromBody] AddPhanCongRequestDTO request)
        {
            var result = await _phanCongService.AddAssignmentAsync(request.GiangVienId, request.ListMaMonHoc);
            if (result)
            {
                return Ok(new { message = "Phân công thành công" });
            }
            return BadRequest(new { message = "Phân công thất bại" });
        }

        [HttpDelete("{maMonHoc}/{maNguoiDung}")]
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
    }


}