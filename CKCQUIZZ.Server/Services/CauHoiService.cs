using CKCQUIZZ.Server.Data;
using CKCQUIZZ.Server.Interfaces;
using CKCQUIZZ.Server.Mappers;
using CKCQUIZZ.Server.Models;
using CKCQUIZZ.Server.Viewmodels.CauHoi;
using Microsoft.EntityFrameworkCore;

namespace CKCQUIZZ.Server.Services
{
    public class CauHoiService : ICauHoiService
    {
        private readonly CkcquizzContext _context;
        public CauHoiService(CkcquizzContext context) { _context = context; }

        public async Task<PagedResult<CauHoiDto>> GetAllPagingAsync(QueryCauHoiDto query)
        {
            var queryable = _context.CauHois.Where(q => q.Trangthai == true).Include(q => q.MamonhocNavigation).Include(q => q.MachuongNavigation).AsQueryable();

            // Filter by creator - only show questions created by current user
            if (!string.IsNullOrEmpty(query.NguoiTao))
            {
                queryable = queryable.Where(q => q.Nguoitao == query.NguoiTao);
            }

            if (query.MaMonHoc.HasValue) queryable = queryable.Where(q => q.Mamonhoc == query.MaMonHoc.Value);
            if (query.MaChuong.HasValue) queryable = queryable.Where(q => q.Machuong == query.MaChuong.Value);
            if (query.DoKho.HasValue) queryable = queryable.Where(q => q.Dokho == query.DoKho.Value);
            if (!string.IsNullOrEmpty(query.Keyword))
            {
                var keywordLower = query.Keyword.ToLower();
                queryable = queryable.Where(q =>
                    q.Noidung.ToLower().Contains(keywordLower) ||
                    (q.MamonhocNavigation != null && q.MamonhocNavigation.Tenmonhoc.ToLower().Contains(keywordLower))
                );
            }


            var totalCount = await queryable.CountAsync();
            var pagedData = await queryable.Skip((query.PageNumber - 1) * query.PageSize).Take(query.PageSize).ToListAsync();
            var dtos = pagedData.Select(p => p.ToCauHoiDto()).ToList();
            return new PagedResult<CauHoiDto> { Items = dtos, TotalCount = totalCount, PageNumber = query.PageNumber, PageSize = query.PageSize };
        }

        public async Task<CauHoiDetailDto> GetByIdAsync(int id)
        {
            var cauHoi = await _context.CauHois.Include(q => q.MamonhocNavigation).Include(q => q.MachuongNavigation).Include(q => q.CauTraLois).FirstOrDefaultAsync(q => q.Macauhoi == id);
            return cauHoi == null ? null : cauHoi.ToCauHoiDetailDto();
        }

        public async Task<int> CreateAsync(CreateCauHoiRequestDto request, string userId)
        {
            var newCauHoi = new CauHoi { Noidung = request.Noidung, Dokho = request.Dokho, Mamonhoc = request.Mamonhoc, 
                Machuong = request.Machuong, Daodapan = request.Daodapan,
                Nguoitao = userId, Trangthai = true ,Loaicauhoi=request.Loaicauhoi,Hinhanhurl=request.Hinhanhurl};
            foreach (var ctlDto in request.CauTraLois) { newCauHoi.CauTraLois.Add(new CauTraLoi { Noidungtl = ctlDto.Noidungtl, Dapan = ctlDto.Dapan }); }
            _context.CauHois.Add(newCauHoi);
            await _context.SaveChangesAsync();
            return newCauHoi.Macauhoi;
        }
        public async Task<List<CauHoiDetailDto>> GetByMaMonHocAsync(int maMonHoc, string userId)
        {
            if (maMonHoc <= 0)
            {
                return new List<CauHoiDetailDto>();
            }
            var cauHois = await _context.CauHois
       .Where(q => q.Mamonhoc == maMonHoc && q.Trangthai == true && q.Nguoitao == userId)
       .Include(q => q.MamonhocNavigation)
       .Include(q => q.MachuongNavigation)
       .Include(q => q.CauTraLois) // Bắt buộc phải Include đáp án
       .OrderBy(q => q.Macauhoi)
       .ToListAsync();
            var dtos = cauHois.Select(ch => ch.ToCauHoiDetailDto()).ToList();

            return dtos;
        }
        public async Task<bool> UpdateAsync(int id, UpdateCauHoiRequestDto request)
        {
            var cauHoi = await _context.CauHois.Include(q => q.CauTraLois).FirstOrDefaultAsync(q => q.Macauhoi == id);
            if (cauHoi == null) return false;

            // Cập nhật thông tin câu hỏi
            cauHoi.Noidung = request.Noidung;
            cauHoi.Dokho = request.Dokho;
            cauHoi.Mamonhoc = request.MaMonHoc;
            cauHoi.Machuong = request.Machuong;
            cauHoi.Daodapan = request.Daodapan;
            cauHoi.Trangthai = request.Trangthai;
            cauHoi.Loaicauhoi = request.Loaicauhoi;
            cauHoi.Hinhanhurl = request.Hinhanhurl;

            // Xử lý cập nhật đáp án một cách an toàn
            // Xóa tất cả đáp án cũ và thêm lại từ request để đảm bảo đồng bộ
            _context.CauTraLois.RemoveRange(cauHoi.CauTraLois);

            // Thêm tất cả đáp án từ request
            foreach (var ctlDto in request.CauTraLois)
            {
                cauHoi.CauTraLois.Add(new CauTraLoi
                {
                    Noidungtl = ctlDto.Noidungtl,
                    Dapan = ctlDto.Dapan
                });
            }

            return await _context.SaveChangesAsync() > 0;
        }
        public async Task<bool> DeleteAsync(int id)
        {
            var cauHoi = await _context.CauHois.FindAsync(id);

            if (cauHoi == null)
            {
                return false; // Không tìm thấy để xóa
            }

            // Đây là Soft Delete!
            cauHoi.Trangthai = false;
            _context.Entry(cauHoi).State = EntityState.Modified;

            return await _context.SaveChangesAsync() > 0;
        }
    }
}