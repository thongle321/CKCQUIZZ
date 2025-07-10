using CKCQUIZZ.Server.Data;
using CKCQUIZZ.Server.Interfaces;
using CKCQUIZZ.Server.Mappers;
using CKCQUIZZ.Server.Models;
using CKCQUIZZ.Server.Viewmodels.CauHoi;
using CKCQUIZZ.Server.Viewmodels.MonHoc;
using DocumentFormat.OpenXml.Packaging;
using DocumentFormat.OpenXml.Spreadsheet;
using Microsoft.AspNetCore.Hosting;
using Microsoft.EntityFrameworkCore;
using System.IO.Compression;
using System.Text.RegularExpressions;

namespace CKCQUIZZ.Server.Services
{
    public class CauHoiService(CkcquizzContext _context) : ICauHoiService
    {
      
        public async Task<PagedResult<CauHoiDto>> GetAllPagingAsync(QueryCauHoiDto query)
        {
            var queryable = _context.CauHois.Where(q => q.Trangthai == true).Include(q => q.MamonhocNavigation).Include(q => q.MachuongNavigation).AsQueryable();
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

        public async Task<CauHoiDetailDto?> GetByIdAsync(int id)
        {
            var cauHoi = await _context.CauHois.Include(q => q.MamonhocNavigation).Include(q => q.MachuongNavigation).Include(q => q.CauTraLois).FirstOrDefaultAsync(q => q.Macauhoi == id);
            return cauHoi == null ? null : cauHoi.ToCauHoiDetailDto();
        }

        public async Task<int> CreateAsync(CreateCauHoiRequestDto request, string userId)
        {
            var newCauHoi = new CauHoi
            {
                Noidung = request.Noidung,
                Dokho = request.Dokho,
                Mamonhoc = request.Mamonhoc,
                Machuong = request.Machuong,
                Daodapan = request.Daodapan,
                Nguoitao = userId,
                Trangthai = true,
                Loaicauhoi = request.Loaicauhoi,
                Hinhanhurl = request.Hinhanhurl
            };
            foreach (var ctlDto in request.CauTraLois) { newCauHoi.CauTraLois.Add(new CauTraLoi { Noidungtl = ctlDto.Noidungtl, Dapan = ctlDto.Dapan }); }
            _context.CauHois.Add(newCauHoi);
            await _context.SaveChangesAsync();
            return newCauHoi.Macauhoi;
        }
        public async Task<List<CauHoiDetailDto>> GetByMaMonHocAsync(int maMonHoc)
        {
            if (maMonHoc <= 0)
            {
                return new List<CauHoiDetailDto>();
            }
            var cauHois = await _context.CauHois
       .Where(q => q.Mamonhoc == maMonHoc && q.Trangthai == true)
       .Include(q => q.MamonhocNavigation)
       .Include(q => q.MachuongNavigation)
       .Include(q => q.CauTraLois)
       .OrderBy(q => q.Macauhoi)
       .ToListAsync();
            var dtos = cauHois.Select(ch => ch.ToCauHoiDetailDto()).ToList();

            return dtos;
        }
        public async Task UpdateAsync(int id, UpdateCauHoiRequestDto request, string userId)
        {
            var cauHoi = await _context.CauHois.Include(q => q.CauTraLois).FirstOrDefaultAsync(q => q.Macauhoi == id);
            if (cauHoi == null)
            {
                throw new KeyNotFoundException($"Không tìm thấy câu hỏi với ID: {id}");
            }    
            if (cauHoi.Nguoitao != userId)
            {
                throw new UnauthorizedAccessException("Bạn không có quyền sửa câu hỏi của người khác.");
            }
            var serverZone = TimeZoneInfo.Local;

            // Chuyển thời gian UTC hiện tại sang giờ Local của server
            var nowInServerTime = TimeZoneInfo.ConvertTimeFromUtc(DateTime.UtcNow, serverZone);
            //Sử dụng giờ Local này để so sánh
            var isUsedInActiveExam = await _context.ChiTietDeThis
                .Join(_context.DeThis, ctdt => ctdt.Made, dt => dt.Made, (ctdt, dt) => new { ctdt, dt })
                .AnyAsync(x => x.ctdt.Macauhoi == id &&
                               x.dt.Thoigiantbatdau.HasValue &&
                               x.dt.Thoigianketthuc.HasValue &&
                               // So sánh giờ Local của server với giờ Local trong DB
                               nowInServerTime >= x.dt.Thoigiantbatdau.Value &&
                               nowInServerTime <= x.dt.Thoigianketthuc.Value);

            if (isUsedInActiveExam)
            {
                 throw new InvalidOperationException("Đề thi đang diễn với câu hỏi, bạn không thể sửa.");
            }
            cauHoi.Noidung = request.Noidung; cauHoi.Dokho = request.Dokho; cauHoi.Mamonhoc = request.MaMonHoc;
            cauHoi.Machuong = request.Machuong; cauHoi.Daodapan = request.Daodapan; cauHoi.Trangthai = request.Trangthai; cauHoi.Loaicauhoi = request.Loaicauhoi;
            cauHoi.Hinhanhurl = request.Hinhanhurl;
            var dtoCtlIds = request.CauTraLois.Select(c => c.Macautl).ToList();
            var ctlToRemove = cauHoi.CauTraLois.Where(c => !dtoCtlIds.Contains(c.Macautl)).ToList();
            _context.CauTraLois.RemoveRange(ctlToRemove);
            foreach (var ctlDto in request.CauTraLois)
            {
                var existingCtl = cauHoi.CauTraLois.FirstOrDefault(c => c.Macautl == ctlDto.Macautl);
                if (existingCtl != null) { existingCtl.Noidungtl = ctlDto.Noidungtl; existingCtl.Dapan = ctlDto.Dapan; }
                else { cauHoi.CauTraLois.Add(new CauTraLoi { Noidungtl = ctlDto.Noidungtl, Dapan = ctlDto.Dapan }); }
            }
             await _context.SaveChangesAsync() ;
        }
        public async Task<bool> DeleteAsync(int id)
        {
            var cauHoi = await _context.CauHois.FindAsync(id);

            if (cauHoi == null)
            {
                return false; 
            }

            cauHoi.Trangthai = false;
            _context.Entry(cauHoi).State = EntityState.Modified;

            return await _context.SaveChangesAsync() > 0;
        }
        public async Task<(bool Success, string Message)> HardDeleteAsync(int id, string userId)
        {
            var cauHoi = await _context.CauHois.Include(ch => ch.CauTraLois).FirstOrDefaultAsync(ch => ch.Macauhoi == id);

            if (cauHoi == null)
            {
                return (false, "Không tìm thấy câu hỏi để xoá.");
            }
            if (cauHoi.Nguoitao != userId)
            {
                return (false, "Bạn không có quyền xoá câu hỏi của người khác.");
            }
            try
            {
                if (cauHoi.CauTraLois.Any())
                {
                    _context.CauTraLois.RemoveRange(cauHoi.CauTraLois);
                }
                _context.CauHois.Remove(cauHoi);
                await _context.SaveChangesAsync();
                return (true, "Xoá câu hỏi thành công.");
            }
            catch (DbUpdateException)
            {
                return (false, "Không thể xoá câu hỏi này vì đã có trong đề thi");
            }
            catch (Exception ex)
            {
                return (false, "Đã có lỗi không mong muốn xảy ra trong quá trình xoá.");
            }
        }
        public async Task<PagedResult<CauHoiDto>> GetQuestionsForAssignedSubjectsAsync(string userId, QueryCauHoiDto query)
        {
            var assignedSubjectIds = await _context.PhanCongs
                .Where(pc => pc.Manguoidung == userId)
                .Select(pc => pc.Mamonhoc)
                .Distinct()
                .ToListAsync();

            if (!assignedSubjectIds.Any())
            {
                return new PagedResult<CauHoiDto> { Items = new List<CauHoiDto>() };
            }

            var queryable = _context.CauHois
                .Where(q => assignedSubjectIds.Contains(q.Mamonhoc)) // Lọc theo các môn được phân công
                .Include(q => q.MamonhocNavigation)
                .Include(q => q.MachuongNavigation)
                .AsQueryable();

            if (query.MaMonHoc.HasValue)
            {
                if (assignedSubjectIds.Contains(query.MaMonHoc.Value))
                {
                    queryable = queryable.Where(q => q.Mamonhoc == query.MaMonHoc.Value);
                }
            }
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
            var pagedData = await queryable
                .OrderBy(q => q.Macauhoi)
                .Skip((query.PageNumber - 1) * query.PageSize)
                .Take(query.PageSize)
                .ToListAsync();

            var dtos = pagedData.Select(p => p.ToCauHoiDto()).ToList();
            return new PagedResult<CauHoiDto> { Items = dtos, TotalCount = totalCount, PageNumber = query.PageNumber, PageSize = query.PageSize };
        }


        public async Task<PagedResult<CauHoiDto>> GetMyCreatedQuestionsAsync(string userId, QueryCauHoiDto query)
        {
            var assignedSubjectIds = await _context.PhanCongs
                .Where(pc => pc.Manguoidung == userId)
                .Select(pc => pc.Mamonhoc)
                .Distinct()
                .ToListAsync();

            if (!assignedSubjectIds.Any())
            {
                return new PagedResult<CauHoiDto> { Items = new List<CauHoiDto>() };
            }


            var queryable = _context.CauHois
                .Where(q => q.Trangthai == true &&
                           assignedSubjectIds.Contains(q.Mamonhoc) &&
                           q.Nguoitao == userId)
                .Include(q => q.MamonhocNavigation)
                .Include(q => q.MachuongNavigation)
                .AsQueryable();

            if (query.MaMonHoc.HasValue)
            {
                queryable = queryable.Where(q => q.Mamonhoc == query.MaMonHoc.Value);
            }

            if (query.MaChuong.HasValue)
            {
                queryable = queryable.Where(q => q.Machuong == query.MaChuong.Value);
            }

            if (query.DoKho.HasValue)
            {
                queryable = queryable.Where(q => q.Dokho == query.DoKho.Value);
            }

            if (!string.IsNullOrEmpty(query.Keyword))
            {
                var keywordLower = query.Keyword.ToLower();
                queryable = queryable.Where(q =>
                    q.Noidung.ToLower().Contains(keywordLower) ||
                    (q.MamonhocNavigation != null && q.MamonhocNavigation.Tenmonhoc.ToLower().Contains(keywordLower))
                );
            }

            var totalCount = await queryable.CountAsync();
            var pagedData = await queryable
                .OrderBy(q => q.Macauhoi)
                .Skip((query.PageNumber - 1) * query.PageSize)
                .Take(query.PageSize)
                .ToListAsync();

            var dtos = pagedData.Select(p => p.ToCauHoiDto()).ToList();
            return new PagedResult<CauHoiDto> { Items = dtos, TotalCount = totalCount, PageNumber = query.PageNumber, PageSize = query.PageSize };
        }

    }
}