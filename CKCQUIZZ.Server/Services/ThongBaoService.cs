using CKCQUIZZ.Server.Interfaces;
using CKCQUIZZ.Server.Models;
using CKCQUIZZ.Server.Viewmodels;
using CKCQUIZZ.Server.Viewmodels.ThongBao;
using Microsoft.EntityFrameworkCore;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using Microsoft.AspNetCore.SignalR;
using CKCQUIZZ.Server.Hubs;

namespace CKCQUIZZ.Server.Services
{
    public class ThongBaoService(CkcquizzContext _context, IHubContext<NotificationHub, INotificationHubClient> _hubContext) : IThongBaoService
    {

        public async Task<ThongBao?> GetByIdAsync(int id)
        {
            return await _context.ThongBaos.FindAsync(id);
        }


        public async Task<ThongBao> CreateAsync(ThongBao thongBao, List<int> lopId, string giangvienId)
        {
            thongBao.Nguoitao = giangvienId;
            thongBao.Thoigiantao = thongBao.Thoigiantao ?? DateTime.Now;

            await _context.ThongBaos.AddAsync(thongBao);
            await _context.SaveChangesAsync();

            foreach (var lopid in lopId)
            {
                var lop = await _context.Lops.FindAsync(lopid);
                if (lop != null)
                {
                    thongBao.Malops.Add(lop);
                }
            }
            await _context.SaveChangesAsync();

            await _context.Entry(thongBao)
                          .Reference(tb => tb.NguoitaoNavigation)
                          .LoadAsync();

            var createdNotificationDTO = new ThongBaoGetAnnounceDTO
            {
                Matb = thongBao.Matb,
                Noidung = thongBao.Noidung,
                Thoigiantao = thongBao.Thoigiantao,
                Avatar = thongBao.NguoitaoNavigation?.Avatar,
                Hoten = thongBao.NguoitaoNavigation?.Hoten,
                Malops = thongBao.Malops.Select(l => l.Malop).ToList()
            };

            foreach (var lopid in lopId)
            {
                string groupName = $"class-{lopid}";
                await _hubContext.Clients.Group(groupName).ReceiveNotification(createdNotificationDTO);
            }

            return thongBao;
        }

        public async Task<List<ThongBaoGetAnnounceDTO>> GetThongBaoByLopIdAsync(int groupId)
        {
            var announcements = await _context.ThongBaos
                .Where(tb => tb.Malops.Any(l => l.Malop == groupId))
                .Include(tb => tb.NguoitaoNavigation)
                .Select(tb => new ThongBaoGetAnnounceDTO
                {
                    Matb = tb.Matb,
                    Avatar = tb.NguoitaoNavigation.Avatar,
                    Noidung = tb.Noidung,
                    Thoigiantao = tb.Thoigiantao,
                    Hoten = tb.NguoitaoNavigation.Hoten
                })
                .OrderByDescending(tb => tb.Thoigiantao)
                .ToListAsync();

            return announcements;
        }

        public async Task<PagedResult<ThongBaoGetAllDTO>> GetAllThongBaoNguoiDungAsync(string userId, int page, int pageSize, string? search = null)
        {
            var query = _context.ThongBaos
                            .Where(tb => tb.Nguoitao == userId);

            if (!string.IsNullOrEmpty(search))
            {
                query = query.Where(tb => tb.Noidung!.Contains(search));
            }

            var projectedQuery = query.Select(tb => new ThongBaoGetAllDTO
            {
                Matb = tb.Matb,
                Noidung = tb.Noidung,
                Thoigiantao = tb.Thoigiantao,
                Tenmonhoc = tb.Malops.Select(l => l.DanhSachLops.FirstOrDefault()!.MamonhocNavigation.Tenmonhoc).FirstOrDefault(),
                Namhoc = tb.Malops.Select(l => l.Namhoc).FirstOrDefault(),
                Hocky = tb.Malops.Select(l => l.Hocky).FirstOrDefault(),
                Nhom = tb.Malops.Select(l => l.Tenlop).ToList()
            }).OrderByDescending(tb => tb.Thoigiantao);

            var totalItems = await projectedQuery.CountAsync();

            var items = await projectedQuery
                .Skip((page - 1) * pageSize)
                .Take(pageSize)
                .ToListAsync();

            return new PagedResult<ThongBaoGetAllDTO> { Items = items, TotalCount = totalItems };
        }

        public async Task<ThongBao?> DeleteAsync(int matb)
        {
            var thongBao = await _context.ThongBaos
                                        .Include(tb => tb.Malops)
                                        .FirstOrDefaultAsync(tb => tb.Matb == matb);

            if (thongBao == null)
            {
                return null;
            }

            thongBao.Malops.Clear();
            await _context.SaveChangesAsync();

            _context.ThongBaos.Remove(thongBao);
            await _context.SaveChangesAsync();
            return thongBao;
        }

        public async Task<ThongBaoDetailDTO?> GetChiTietThongBaoAsync(int matb)
        {
            var thongBao = await _context.ThongBaos
                .Where(tb => tb.Matb == matb)
                .Select(tb => new ThongBaoDetailDTO
                {
                    Matb = tb.Matb,
                    Noidung = tb.Noidung,
                    Mamonhoc = tb.Malops.Select(l => l.DanhSachLops.FirstOrDefault()!.Mamonhoc).FirstOrDefault(),
                    Tenmonhoc = tb.Malops.Select(l => l.DanhSachLops.FirstOrDefault()!.MamonhocNavigation.Tenmonhoc).FirstOrDefault(),
                    Namhoc = tb.Malops.Select(l => l.Namhoc).FirstOrDefault(),
                    Hocky = tb.Malops.Select(l => l.Hocky).FirstOrDefault(),
                    Nhom = tb.Malops.Select(l => l.Malop).ToList() // Lấy danh sách ID của các nhóm
                })
                .FirstOrDefaultAsync();

            return thongBao;
        }

        public async Task<ThongBao?> UpdateAsync(int matb, UpdateThongBaoRequestDTO thongBaoDTO, List<int> nhomIds)
        {
            var existingThongBao = await _context.ThongBaos
                                                 .Include(tb => tb.Malops)
                                                 .FirstOrDefaultAsync(tb => tb.Matb == matb);

            if (existingThongBao == null)
            {
                return null;
            }

            existingThongBao.Noidung = thongBaoDTO.Noidung;

            existingThongBao.Malops.Clear();

            foreach (var nhomId in nhomIds)
            {
                var lop = await _context.Lops.FindAsync(nhomId);
                if (lop != null)
                {
                    existingThongBao.Malops.Add(lop);
                }
            }

            await _context.SaveChangesAsync();
            return existingThongBao;
        }

        public async Task<List<ThongBaoDTO>> GetTinNhanChoNguoiDungAsync(string userId)
        {

            var sqlQuery = @$"
                SELECT
                    tb.matb,
                    tb.nguoitao,
                    l.tenlop,
                    nd.avatar,
                    nd.hoten,
                    tb.noidung,
                    tb.thoigiantao,
                    l.malop,
                    mh.Mamonhoc,
                    mh.Tenmonhoc
                FROM
                    ThongBao AS tb
                JOIN
                    ChiTietThongBao AS cttb ON tb.matb = cttb.matb
                JOIN
                    Lop AS l ON cttb.malop = l.malop
                JOIN
                    ChiTietLop AS ctl ON l.malop = ctl.malop
                JOIN
                    NguoiDung AS nd ON tb.nguoitao = nd.Id
                JOIN
                    DanhSachLop AS dsl ON l.malop = dsl.malop
                JOIN
                    MonHoc AS mh ON dsl.mamonhoc = mh.mamonhoc
                WHERE
                    ctl.manguoidung = {{0}}
                ORDER BY
                    tb.thoigiantao DESC
                OFFSET 0 ROWS FETCH NEXT 5 ROWS ONLY";

            var notifications = await _context.Database.SqlQueryRaw<ThongBaoDTO>(sqlQuery, userId).ToListAsync();
            return notifications;
        }

        public async Task<PagedResult<ThongBaoGetAllDTO>> GetAllThongBaoAsync(int page, int pageSize, string? search = null)
        {
            var query = _context.ThongBaos.AsQueryable();

            if (!string.IsNullOrEmpty(search))
            {
                query = query.Where(tb => tb.Noidung!.Contains(search));
            }

            var projectedQuery = query.Select(tb => new ThongBaoGetAllDTO
            {
                Matb = tb.Matb,
                Noidung = tb.Noidung,
                Thoigiantao = tb.Thoigiantao,
                Tenmonhoc = tb.Malops.Select(l => l.DanhSachLops.FirstOrDefault()!.MamonhocNavigation.Tenmonhoc).FirstOrDefault(),
                Namhoc = tb.Malops.Select(l => l.Namhoc).FirstOrDefault(),
                Hocky = tb.Malops.Select(l => l.Hocky).FirstOrDefault(),
                Nhom = tb.Malops.Select(l => l.Tenlop).ToList()
            }).OrderByDescending(tb => tb.Thoigiantao);

            var totalItems = await projectedQuery.CountAsync();

            var items = await projectedQuery
                .Skip((page - 1) * pageSize)
                .Take(pageSize)
                .ToListAsync();

            return new PagedResult<ThongBaoGetAllDTO> { Items = items, TotalCount = totalItems };
        }
    }
}

