// Services/DeThiService.cs
using CKCQUIZZ.Server.Data;
using CKCQUIZZ.Server.Interfaces;
using CKCQUIZZ.Server.Models;
using CKCQUIZZ.Server.Viewmodels.DeThi;
using Microsoft.EntityFrameworkCore;
using System.Security.Claims;

namespace CKCQUIZZ.Server.Services
{
    public class DeThiService : IDeThiService
    {
        private readonly CkcquizzContext _context;
        private readonly IHttpContextAccessor _httpContextAccessor;
        public DeThiService(CkcquizzContext context, IHttpContextAccessor httpContextAccessor)
        {
            _context = context;
            _httpContextAccessor = httpContextAccessor;
        }

        // READ ALL
        public async Task<List<DeThiViewModel>> GetAllAsync()
        {
            var deThis = await _context.DeThis
                .Include(d => d.Malops)
                .Include(d => d.Malops) // Nạp danh sách các lớp được gán
                .OrderByDescending(d => d.Thoigiantao)
                .ToListAsync();

            var viewModels = deThis.Select(d => new DeThiViewModel
            {
                Made = d.Made,
                Tende = d.Tende,
                Thoigianbatdau = d.Thoigiantbatdau ?? DateTime.MinValue, // Giả định không null
                Thoigianketthuc = d.Thoigianketthuc ?? DateTime.MinValue,
                Monthi = d.Monthi??0,
                GiaoCho = d.Malops.Any() ? string.Join(", ", d.Malops.Select(l => l.Tenlop)) : "Chưa giao",
                Trangthai = d.Trangthai ?? false
            }).ToList();

            return viewModels;
        }

        // READ ONE
        public async Task<DeThiDetailViewModel> GetByIdAsync(int id)
        {
            var deThi = await _context.DeThis
                .Include(d => d.Malops)
                .Include(d => d.ChiTietDeThis).ThenInclude(ct => ct.MacauhoiNavigation)
                .FirstOrDefaultAsync(d => d.Made == id);

            if (deThi == null) return null;

            return new DeThiDetailViewModel
            {
                Made = deThi.Made,
                Tende = deThi.Tende,
                Monthi = deThi.Monthi,
                Thoigianthi = deThi.Thoigianthi ?? 0,
                Thoigiantbatdau = deThi.Thoigiantbatdau ?? DateTime.MinValue,
                Thoigianketthuc = deThi.Thoigianketthuc ?? DateTime.MinValue,
                Xemdiemthi = deThi.Xemdiemthi ?? false,
                Hienthibailam = deThi.Hienthibailam ?? false,
                Xemdapan = deThi.Xemdapan ?? false,
                Troncauhoi = deThi.Troncauhoi ?? false,
                Loaide = deThi.Loaide ?? 1,
                Socaude = deThi.Socaude ?? 0,
                Socautb = deThi.Socautb ?? 0,
                Socaukho = deThi.Socaukho ?? 0,
                Malops = deThi.Malops.Select(l => l.Malop).ToList(),
                Machuongs = deThi.ChiTietDeThis.Select(ct => ct.MacauhoiNavigation.Machuong).Distinct().ToList()
            };
        }

        // CREATE (Code của bạn đã tốt, tôi chỉ tinh chỉnh một chút)
        public async Task<DeThiViewModel> CreateAsync(DeThiCreateRequest request)
        {
            var creatorId = _httpContextAccessor.HttpContext?.User?.FindFirstValue(ClaimTypes.NameIdentifier);
            if (string.IsNullOrEmpty(creatorId))
            {
                // Ném ra lỗi hoặc xử lý trường hợp không có người dùng
                throw new UnauthorizedAccessException("Không thể xác định người dùng.");
            }
            var newDeThi = new DeThi
            {
                Tende = request.Tende,
                Thoigiantbatdau = request.Thoigianbatdau.ToUniversalTime(),
                Thoigianketthuc = request.Thoigianketthuc.ToUniversalTime(),
                Thoigianthi = request.Thoigianthi,
                Monthi = request.Monthi,
                Xemdiemthi = request.Xemdiemthi,
                Hienthibailam = request.Hienthibailam,
                Xemdapan = request.Xemdapan,
                Troncauhoi = request.Troncauhoi,
                Loaide = request.Loaide,
                Socaude = request.Socaude,
                Socautb = request.Socautb,
                Socaukho = request.Socaukho,
                Nguoitao = creatorId,
                Thoigiantao = DateTime.UtcNow,
                Trangthai = true
            };

            var selectedLops = await _context.Lops.Where(l => request.Malops.Contains(l.Malop)).ToListAsync();
            newDeThi.Malops = selectedLops;

            // Logic lấy câu hỏi
            if (request.Loaide == 1 && request.Machuongs.Any())
            {
                var cauDe = await GetRandomQuestionsByDifficulty(request.Machuongs, 1, request.Socaude);
                var cauTB = await GetRandomQuestionsByDifficulty(request.Machuongs, 2, request.Socautb);
                var cauKho = await GetRandomQuestionsByDifficulty(request.Machuongs, 3, request.Socaukho);

                foreach (var question in cauDe.Concat(cauTB).Concat(cauKho))
                {
                    newDeThi.ChiTietDeThis.Add(new ChiTietDeThi { Macauhoi = question.Macauhoi, Diemcauhoi = 1 });
                }
            }

            _context.DeThis.Add(newDeThi);
            await _context.SaveChangesAsync();

            return new DeThiViewModel
            {
                Made = newDeThi.Made,
                Tende = newDeThi.Tende,
                Thoigianbatdau = newDeThi.Thoigiantbatdau.Value,
                Thoigianketthuc = newDeThi.Thoigianketthuc.Value,
                // Dùng lại logic của GetAllAsync để tạo chuỗi "GiaoCho"
                GiaoCho = newDeThi.Malops.Any() ? string.Join(", ", newDeThi.Malops.Select(l => l.Tenlop)) : "Chưa giao",
                // Dùng lại logic của GetAllAsync để xác định "Trangthai"
                Trangthai = newDeThi.Trangthai ?? false
            };
        }

        // UPDATE
        public async Task<bool> UpdateAsync(int id, DeThiUpdateRequest request)
        {
            var deThi = await _context.DeThis
                .Include(d => d.Malops)
                .FirstOrDefaultAsync(d => d.Made == id);

            if (deThi == null) return false;

            // Cập nhật các thuộc tính
            deThi.Tende = request.Tende;
            deThi.Thoigiantbatdau = request.Thoigianbatdau.ToUniversalTime();
            // ... các trường khác

            // Cập nhật danh sách lớp được giao
            deThi.Malops.Clear();
            var newLops = await _context.Lops.Where(l => request.Malops.Contains(l.Malop)).ToListAsync();
            foreach (var lop in newLops)
            {
                deThi.Malops.Add(lop);
            }

            // Logic cập nhật câu hỏi phức tạp hơn, có thể cần xóa chi tiết cũ và thêm mới
            // Tạm thời bỏ qua để đơn giản

            _context.DeThis.Update(deThi);
            await _context.SaveChangesAsync();
            return true;
        }

        // DELETE
        public async Task<bool> DeleteAsync(int id)
        {
            var deThi = await _context.DeThis.FindAsync(id);
            if (deThi == null) return false;
            deThi.Trangthai=false;
            _context.Entry(deThi).State=EntityState.Modified;
            
            return await _context.SaveChangesAsync()>0;
        }
        public async Task<bool> CapNhatChiTietDeThiAsync(int maDe, CapNhatChiTietDeThiRequest request)
        {
            // Tìm đề thi và các chi tiết hiện có
            var deThi = await _context.DeThis
                .Include(d => d.ChiTietDeThis)
                .FirstOrDefaultAsync(d => d.Made == maDe);

            if (deThi == null)
            {
                return false; // Trả về false để Controller biết là NotFound
            }

            // Xóa tất cả các chi tiết cũ
            _context.ChiTietDeThis.RemoveRange(deThi.ChiTietDeThis);

            // Thêm lại các chi tiết mới từ danh sách ID mà client gửi lên
            if (request.MaCauHois != null && request.MaCauHois.Any())
            {
                var newChiTietList = request.MaCauHois.Select(maCauHoi => new ChiTietDeThi
                {
                    Made = maDe,
                    Macauhoi = maCauHoi,
                    Diemcauhoi = 1 // hoặc một giá trị mặc định nào đó
                }).ToList();

                await _context.ChiTietDeThis.AddRangeAsync(newChiTietList);
            }

            // Lưu tất cả thay đổi
            return await _context.SaveChangesAsync() > 0;
        }
        private async Task<List<CauHoi>> GetRandomQuestionsByDifficulty(List<int> chuongIds, int doKho, int count)
        {
            if (count <= 0) return new List<CauHoi>();
            return await _context.CauHois
                .Where(q => chuongIds.Contains(q.Machuong) && q.Dokho == doKho && q.Trangthai == true)
                .OrderBy(q => Guid.NewGuid())
                .Take(count)
                .ToListAsync();
        }
    }
}