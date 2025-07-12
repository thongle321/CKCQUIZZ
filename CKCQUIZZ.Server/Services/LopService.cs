using CKCQUIZZ.Server.Interfaces;
using CKCQUIZZ.Server.Models;
using CKCQUIZZ.Server.Viewmodels;
using CKCQUIZZ.Server.Viewmodels.Lop;
using CKCQUIZZ.Server.Viewmodels.NguoiDung;
using ClosedXML.Excel;
using Microsoft.EntityFrameworkCore;
using QuestPDF.Fluent;
using QuestPDF.Helpers;
using QuestPDF.Infrastructure;
using Microsoft.AspNetCore.Identity;

namespace CKCQUIZZ.Server.Services
{
    public class LopService(CkcquizzContext _context, UserManager<NguoiDung> _userManager) : ILopService
    {

        public async Task<List<Lop>> GetAllAsync(string userId, bool? hienthi, string userRole, string? searchQuery)
        {
            var query = _context.Lops
                .Include(l => l.ChiTietLops)
                .Include(l => l.DanhSachLops)
                    .ThenInclude(dsl => dsl.MamonhocNavigation)
                .Include(l => l.GiangvienNavigation)
                .Where(l => l.Trangthai == true)
                .AsQueryable();

            if (!string.IsNullOrWhiteSpace(searchQuery))
            {
                var lowerCaseSearchQuery = searchQuery.Trim().ToLower();
                query = query.Where(l =>
                    l.Tenlop.Contains(lowerCaseSearchQuery, StringComparison.CurrentCultureIgnoreCase) ||
                    (l.DanhSachLops.Any() && l.DanhSachLops.First().MamonhocNavigation.Tenmonhoc.Contains(lowerCaseSearchQuery, StringComparison.CurrentCultureIgnoreCase)) ||
                    (l.GiangvienNavigation != null && l.GiangvienNavigation.Hoten.ToLower().Contains(lowerCaseSearchQuery)));
            }

            switch (userRole?.ToLower())
            {
                case "admin":
                    break;

                case "teacher":
                    query = query.Where(l => l.Giangvien == userId);
                    break;

                case "student":
                    query = query.Where(l => l.ChiTietLops.Any(ctl => ctl.Manguoidung == userId && ctl.Trangthai == true));
                    break;

                default:
                    return [];
            }

            if (hienthi.HasValue)
            {
                query = query.Where(l => l.Hienthi == hienthi.Value);
            }

            return await query.ToListAsync();
        }

        public async Task<Lop?> GetByIdAsync(int id)
        {
            return await _context.Lops
            .Include(l => l.ChiTietLops)
            .Include(l => l.DanhSachLops)
            .ThenInclude(dsl => dsl.MamonhocNavigation)
            .Include(l => l.GiangvienNavigation)
            .FirstOrDefaultAsync(l => l.Malop == id);

        }

        public async Task<Lop> CreateAsync(Lop lopModel, int mamonhoc, string giangvienId)
        {
            lopModel.Giangvien = giangvienId;
            lopModel.Mamoi = Guid.NewGuid().ToString().ToUpper().Substring(0, 6);

            await _context.Lops.AddAsync(lopModel);
            await _context.SaveChangesAsync();

            await _context.DanhSachLops.AddAsync(new DanhSachLop { Malop = lopModel.Malop, Mamonhoc = mamonhoc });
            await _context.SaveChangesAsync();

            var createdLop = await _context.Lops
                .Include(l => l.ChiTietLops)
                .Include(l => l.DanhSachLops)
                    .ThenInclude(dsl => dsl.MamonhocNavigation)
                .Include(l => l.GiangvienNavigation)
                .FirstOrDefaultAsync(l => l.Malop == lopModel.Malop);
            return createdLop ?? throw new Exception("Không thể tìm thấy lớp vừa được tạo.");
        }

        public async Task<Lop?> UpdateAsync(int id, UpdateLopRequestDTO lopDTO)
        {
            var existingLop = await _context.Lops
                .Include(l => l.DanhSachLops)
                .FirstOrDefaultAsync(x => x.Malop == id);

            if (existingLop is null)
            {
                return null;
            }

            existingLop.Tenlop = lopDTO.Tenlop;
            existingLop.Ghichu = lopDTO.Ghichu;
            existingLop.Namhoc = lopDTO.Namhoc;
            existingLop.Hocky = lopDTO.Hocky;
            existingLop.Trangthai = lopDTO.Trangthai;
            existingLop.Hienthi = lopDTO.Hienthi;

            if (!string.IsNullOrEmpty(lopDTO.GiangvienId))
            {
                existingLop.Giangvien = lopDTO.GiangvienId;
            }

            _context.DanhSachLops.RemoveRange(existingLop.DanhSachLops);

            existingLop.DanhSachLops.Add(new DanhSachLop { Malop = id, Mamonhoc = lopDTO.Mamonhoc });

            await _context.SaveChangesAsync();

            return existingLop;
        }

        public async Task<Lop?> DeleteAsync(int id)
        {
            var lopModel = await _context.Lops.FirstOrDefaultAsync(x => x.Malop == id);
            if (lopModel is null)
            {
                return null;
            }
            var chiTietLopModel = _context.ChiTietLops.Where(x => x.Malop == id);
            _context.ChiTietLops.RemoveRange(chiTietLopModel);
            var danhSachLopModel = _context.DanhSachLops.Where(x => x.Malop == id);
            _context.DanhSachLops.RemoveRange(danhSachLopModel);

            _context.Lops.Remove(lopModel);

            await _context.SaveChangesAsync();
            return lopModel;
        }

        public async Task<Lop?> SoftDeleteAsync(int id)
        {
            var lop = await _context.Lops.FindAsync(id);
            if (lop == null) return null;

            lop.Trangthai = false;
            await _context.SaveChangesAsync();
            return lop;
        }

        public async Task<Lop?> ToggleStatusAsync(int id, bool hienthi)
        {
            var lop = await _context.Lops.FindAsync(id);
            if (lop == null) return null;

            lop.Hienthi = hienthi;
            await _context.SaveChangesAsync();
            return lop;
        }

        public async Task<string?> RefreshInviteCodeAsync(int id)
        {
            var lop = await _context.Lops.FindAsync(id);
            if (lop == null) return null;

            var newCode = Guid.NewGuid().ToString().ToUpper().Substring(0, 6);
            lop.Mamoi = newCode;
            await _context.SaveChangesAsync();
            return newCode;
        }

        public async Task<PagedResult<GetNguoiDungDTO>> GetStudentsInClassAsync(int lopId, int pageNumber, int pageSize, string? searchQuery)
        {
            var query = _context.ChiTietLops
                .Where(ctl => ctl.Malop == lopId && ctl.Trangthai == true)
                .Select(ctl => ctl.ManguoidungNavigation);

            if (!string.IsNullOrWhiteSpace(searchQuery))
            {
                var lowerCaseSearchQuery = searchQuery.Trim().ToLower();
                query = query.Where(sv =>
                    sv.Hoten.Contains(lowerCaseSearchQuery, StringComparison.CurrentCultureIgnoreCase) ||
                    sv.UserName!.Contains(lowerCaseSearchQuery, StringComparison.CurrentCultureIgnoreCase) ||
                    sv.Email!.Contains(lowerCaseSearchQuery, StringComparison.CurrentCultureIgnoreCase) ||
                    sv.Id.Contains(lowerCaseSearchQuery, StringComparison.CurrentCultureIgnoreCase));
            }

            var totalCount = await query.CountAsync();

            var fromDb = await query.Skip((pageNumber - 1) * pageSize)
                                   .Take(pageSize)
                                   .ToListAsync();

            var students = fromDb.Select(student => new GetNguoiDungDTO
            {
                MSSV = student.Id,
                Hoten = student.Hoten,
                Email = student.Email!,
                Ngaysinh = student.Ngaysinh,
                PhoneNumber = student.PhoneNumber!,
                Gioitinh = student.Gioitinh,
                Trangthai = student.Trangthai,
            }).ToList();

            return new PagedResult<GetNguoiDungDTO>
            {
                TotalCount = totalCount,
                Items = students
            };

        }
        public async Task<ChiTietLop?> AddStudentToClassAsync(int lopId, string manguoidungId)
        {
            var lopExists = await _context.Lops.AnyAsync(l => l.Malop == lopId);
            var userExists = await _context.NguoiDungs.AnyAsync(u => u.Id == manguoidungId);

            if (!lopExists || !userExists)
            {
                throw new InvalidOperationException("Lớp học không tồn tại hoặc sinh viên không tồn tại");
            }

            var alreadyInClass = await _context.ChiTietLops
                .AnyAsync(ctl => ctl.Malop == lopId && ctl.Manguoidung == manguoidungId);

            if (alreadyInClass)
            {
                throw new InvalidOperationException("Sinh viên đã có trong lớp");
            }

            var chiTietLop = new ChiTietLop
            {
                Malop = lopId,
                Manguoidung = manguoidungId,
                Trangthai = true
            };

            await _context.ChiTietLops.AddAsync(chiTietLop);
            await _context.SaveChangesAsync();
            return chiTietLop;
        }

        public async Task<bool> KickStudentFromClassAsync(int lopId, string manguoidungId)
        {
            var chiTietLop = await _context.ChiTietLops
                .FirstOrDefaultAsync(ctl => ctl.Malop == lopId && ctl.Manguoidung == manguoidungId);

            if (chiTietLop == null) return false;

            _context.ChiTietLops.Remove(chiTietLop);
            await _context.SaveChangesAsync();
            return true;
        }

        public async Task<List<MonHocWithNhomLopDTO>> GetSubjectsAndGroupsAsync(bool? hienthi)
        {
            var query = _context.Lops.AsQueryable();

            if (hienthi.HasValue)
            {
                query = query.Where(l => l.Hienthi == hienthi.Value);
            }

            var lopsWithMonHoc = await query
                .Include(l => l.DanhSachLops)
                    .ThenInclude(dsl => dsl.MamonhocNavigation)
                .ToListAsync();

            var groupedData = lopsWithMonHoc
                .Where(l => l.DanhSachLops.Count != 0)
                .GroupBy(l => new
                {
                    l.DanhSachLops.First().MamonhocNavigation.Mamonhoc,
                    l.DanhSachLops.First().MamonhocNavigation.Tenmonhoc,
                    l.Namhoc,
                    l.Hocky
                })
                .Select(g => new MonHocWithNhomLopDTO
                {
                    Mamonhoc = g.Key.Mamonhoc,
                    Tenmonhoc = g.Key.Tenmonhoc,
                    Namhoc = g.Key.Namhoc,
                    Hocky = g.Key.Hocky,
                    NhomLop = g.Select(l => new NhomLopInMonHocDTO { Manhom = l.Malop, Tennhom = l.Tenlop }).ToList()
                })
                .OrderBy(m => m.Tenmonhoc)
                .ToList();

            return groupedData;
        }

        public async Task<List<MonHocWithNhomLopDTO>> GetSubjectsAndGroupsForTeacherAsync(string teacherId, bool? hienthi)
        {
            var query = _context.Lops
                .Where(l => l.Giangvien == teacherId);

            if (hienthi.HasValue)
            {
                query = query.Where(l => l.Hienthi == hienthi.Value);
            }

            var lopsWithMonHoc = await query
                .Include(l => l.DanhSachLops)
                    .ThenInclude(dsl => dsl.MamonhocNavigation)
                .ToListAsync();

            var groupedData = lopsWithMonHoc
                .Where(l => l.DanhSachLops.Count != 0)
                .GroupBy(l => new
                {
                    l.DanhSachLops.First().MamonhocNavigation.Mamonhoc,
                    l.DanhSachLops.First().MamonhocNavigation.Tenmonhoc,
                    l.Namhoc,
                    l.Hocky
                })
                .Select(g => new MonHocWithNhomLopDTO
                {
                    Mamonhoc = g.Key.Mamonhoc,
                    Tenmonhoc = g.Key.Tenmonhoc,
                    Namhoc = g.Key.Namhoc,
                    Hocky = g.Key.Hocky,
                    NhomLop = g.Select(l => new NhomLopInMonHocDTO { Manhom = l.Malop, Tennhom = l.Tenlop }).ToList()
                })
                .OrderBy(m => m.Tenmonhoc)
                .ToList();

            return groupedData;
        }

        public async Task<ChiTietLop?> JoinClassByInviteCodeAsync(string inviteCode, string studentId)
        {
            var lop = await _context.Lops
                .FirstOrDefaultAsync(l => l.Mamoi == inviteCode && l.Trangthai == true && l.Hienthi == true);

            if (lop == null) return null;

            var userExists = await _context.NguoiDungs.AnyAsync(u => u.Id == studentId);
            if (!userExists) return null;

            var alreadyInClass = await _context.ChiTietLops
                .AnyAsync(ctl => ctl.Malop == lop.Malop && ctl.Manguoidung == studentId);

            if (alreadyInClass) return null;

            var chiTietLop = new ChiTietLop
            {
                Malop = lop.Malop,
                Manguoidung = studentId,
                Trangthai = false
            };

            await _context.ChiTietLops.AddAsync(chiTietLop);
            await _context.SaveChangesAsync();
            return chiTietLop;
        }

        public async Task<int> GetPendingRequestCountAsync(int lopId)
        {
            return await _context.ChiTietLops
                .CountAsync(ctl => ctl.Malop == lopId && ctl.Trangthai == false);
        }

        public async Task<List<PendingStudentDTO>> GetPendingStudentsAsync(int lopId)
        {
            var pendingStudents = await _context.ChiTietLops
                .Where(ctl => ctl.Malop == lopId && ctl.Trangthai == false)
                .Include(ctl => ctl.ManguoidungNavigation)
                .Select(ctl => new PendingStudentDTO
                {
                    Manguoidung = ctl.Manguoidung,
                    Hoten = ctl.ManguoidungNavigation.Hoten,
                    Email = ctl.ManguoidungNavigation.Email!,
                    Mssv = ctl.ManguoidungNavigation.Id,
                    NgayYeuCau = null
                })
                .ToListAsync();

            return pendingStudents;
        }

        public async Task<bool> ApproveJoinRequestAsync(int lopId, string studentId)
        {
            var chiTietLop = await _context.ChiTietLops
                .FirstOrDefaultAsync(ctl => ctl.Malop == lopId && ctl.Manguoidung == studentId && ctl.Trangthai == false);

            if (chiTietLop == null) return false;

            chiTietLop.Trangthai = true;
            await _context.SaveChangesAsync();
            return true;
        }

        public async Task<bool> RejectJoinRequestAsync(int lopId, string studentId)
        {
            var chiTietLop = await _context.ChiTietLops
                .FirstOrDefaultAsync(ctl => ctl.Malop == lopId && ctl.Manguoidung == studentId && ctl.Trangthai == false);

            if (chiTietLop == null) return false;

            _context.ChiTietLops.Remove(chiTietLop);
            await _context.SaveChangesAsync();
            return true;
        }

        public async Task<List<GetNguoiDungDTO>> GetTeachersInClassAsync(int lopId)
        {
            var teachers = await _context.Lops
                .Where(l => l.Malop == lopId)
                .Select(l => l.GiangvienNavigation)
                .Where(gv => gv != null)
                .Select(gv => new GetNguoiDungDTO
                {
                    MSSV = gv.Id,
                    Hoten = gv.Hoten,
                    Email = gv.Email!,
                    Ngaysinh = gv.Ngaysinh,
                    PhoneNumber = gv.PhoneNumber!,
                    Gioitinh = gv.Gioitinh,
                    Trangthai = gv.Trangthai,
                })
                .ToListAsync();

            return teachers!;
        }
        public async Task<byte[]?> ExportScoreboardPdfAsync(int lopId)
        {
            var lop = await _context.Lops
                .Include(l => l.DanhSachLops)
                    .ThenInclude(dsl => dsl.MamonhocNavigation)
                .Include(l => l.ChiTietLops)
                    .ThenInclude(ctl => ctl.ManguoidungNavigation)
                .Include(l => l.Mades)
                .FirstOrDefaultAsync(l => l.Malop == lopId);

            if (lop is null)
            {
                return null;
            }

            var students = lop.ChiTietLops
                .Where(ctl => ctl.Trangthai == true)
                .Select(ctl => ctl.ManguoidungNavigation)
                .ToList();

            if (students.Count is 0)
            {
                return null;
            }

            var examsInClass = lop.Mades.OrderBy(d => d.Tende).ToList();

            var allScores = await _context.KetQuas
                .Where(kq => examsInClass.Select(e => e.Made).Contains(kq.Made) &&
                             students.Select(s => s.Id).Contains(kq.Manguoidung))
                .ToListAsync();

            var studentScores = new Dictionary<string, Dictionary<int, double?>>();
            foreach (var student in students)
            {
                studentScores[student.Id] = [];
                foreach (var exam in examsInClass)
                {
                    var score = allScores.FirstOrDefault(kq => kq.Manguoidung == student.Id && kq.Made == exam.Made)?.Diemthi;
                    studentScores[student.Id][exam.Made] = score;
                }
            }

            var subjectName = lop.DanhSachLops.FirstOrDefault()?.MamonhocNavigation?.Tenmonhoc ?? "N/A";
            var className = lop.Tenlop ?? "N/A";
            var academicYear = lop.Namhoc?.ToString() ?? "N/A";
            var semester = lop.Hocky?.ToString() ?? "N/A";

            try
            {
                var document = Document.Create(container =>
                {
                    container.Page(page =>
                    {
                        page.Size(PageSizes.A4);
                        page.Margin(50);
                        page.DefaultTextStyle(x => x.FontSize(10));

                        page.Header()
                            .Column(column =>
                            {
                                column.Item().AlignCenter().Text("TRƯỜNG CAO ĐẲNG KỸ THUẬT CAO THẮNG").ExtraBlack().FontSize(16);
                                column.Item().AlignCenter().Text("HỆ THỐNG THI TRẮC NGHIỆM CKCQUIZZ").SemiBold().FontSize(12);
                                column.Item().PaddingTop(10).AlignCenter().Text($"BẢNG ĐIỂM LỚP: {subjectName} - NH {academicYear} - HK{semester} - {className}")
                                    .SemiBold().FontSize(14);
                            });

                        page.Content()
                            .PaddingVertical(10)
                            .Table(table =>
                            {
                                table.ColumnsDefinition(columns =>
                                {
                                    columns.RelativeColumn(1);
                                    columns.RelativeColumn(3);
                                    columns.RelativeColumn(2);
                                    columns.RelativeColumn(1.5f);
                                    columns.RelativeColumn(2);

                                    foreach (var exam in examsInClass)
                                    {
                                        columns.RelativeColumn(1.5f);
                                    }
                                });

                                table.Header(header =>
                                {
                                    header.Cell().Element(CellStyle).Text("STT").SemiBold();
                                    header.Cell().Element(CellStyle).Text("Họ tên").SemiBold();
                                    header.Cell().Element(CellStyle).Text("MSSV").SemiBold();
                                    header.Cell().Element(CellStyle).Text("Giới tính").SemiBold();
                                    header.Cell().Element(CellStyle).Text("Ngày sinh").SemiBold();

                                    foreach (var exam in examsInClass)
                                    {
                                        header.Cell().Element(CellStyle).Text(exam.Tende ?? "N/A").SemiBold();
                                    }

                                    static IContainer CellStyle(IContainer container)
                                    {
                                        return container.BorderBottom(1).BorderColor(Colors.Grey.Lighten2).PaddingVertical(5).AlignCenter();
                                    }
                                });

                                foreach (var (student, index) in students.Select((s, i) => (s, i)))
                                {
                                    table.Cell().Element(CellStyle).Text((index + 1).ToString());
                                    table.Cell().Element(CellStyle).Text(student.Hoten ?? "");
                                    table.Cell().Element(CellStyle).Text(student.Id ?? "");
                                    table.Cell().Element(CellStyle).Text(student.Gioitinh.HasValue ? (student.Gioitinh.Value ? "Nam" : "Nữ") : "N/A");
                                    table.Cell().Element(CellStyle).Text(student.Ngaysinh?.ToString("dd/MM/yyyy") ?? "N/A");

                                    foreach (var exam in examsInClass)
                                    {
                                        var score = studentScores[student.Id][exam.Made];
                                        table.Cell().Element(CellStyle).Text(score.HasValue ? score.Value.ToString("F2") : "N/A");
                                    }

                                    static IContainer CellStyle(IContainer container)
                                    {
                                        return container.BorderBottom(1).BorderColor(Colors.Grey.Lighten3).PaddingVertical(3).AlignCenter();
                                    }
                                }
                            });

                        page.Footer()
                            .AlignCenter()
                            .Text(x =>
                            {
                                x.Span("Trang ");
                                x.CurrentPageNumber();
                                x.Span(" / ");
                                x.TotalPages();
                            });
                    });
                });

                return document.GeneratePdf();
            }
            catch (Exception ex)
            {
                Console.WriteLine($"Lỗi export PDF: {ex.Message}");
                return null;
            }
        }

        public async Task<byte[]?> ExportStudentsToExcelAsync(int lopId)
        {
            var lop = await _context.Lops
                .Include(l => l.ChiTietLops)
                    .ThenInclude(ctl => ctl.ManguoidungNavigation)
                .FirstOrDefaultAsync(l => l.Malop == lopId);

            if (lop is null)
            {
                return null;
            }

            var students = lop.ChiTietLops
                .Where(ctl => ctl.Trangthai == true)
                .Select(ctl => ctl.ManguoidungNavigation)
                .ToList();

            if (students.Count is 0)
            {
                return null;
            }

            var className = lop.Tenlop ?? "N/A";
            var academicYear = lop.Namhoc?.ToString() ?? "N/A";
            var semester = lop.Hocky?.ToString() ?? "N/A";

            using var workbook = new XLWorkbook();
            var worksheet = workbook.Worksheets.Add("DanhSachSinhVien");

            worksheet.Cell("A1").Value = $"DANH SÁCH SINH VIÊN LỚP: {className} - NĂM HỌC: {academicYear} - HỌC KỲ: {semester}";
            worksheet.Range("A1:I1").Merge();
            worksheet.Cell("A1").Style.Font.SetBold();
            worksheet.Cell("A1").Style.Font.SetFontSize(14);
            worksheet.Cell("A1").Style.Alignment.SetHorizontal(XLAlignmentHorizontalValues.Center);
            worksheet.Cell("A1").Style.Alignment.SetVertical(XLAlignmentVerticalValues.Center);

            worksheet.Cell("A2").Value = "STT";
            worksheet.Cell("B2").Value = "Họ tên";
            worksheet.Cell("C2").Value = "MSSV";
            worksheet.Cell("D2").Value = "Email";
            worksheet.Cell("E2").Value = "Giới tính";
            worksheet.Cell("F2").Value = "Ngày sinh";
            worksheet.Cell("G2").Value = "Số điện thoại";

            worksheet.Row(2).Style.Font.SetBold();

            for (int i = 0; i < students.Count; i++)
            {
                var student = students[i];
                int row = i + 3;

                worksheet.Cell(row, 1).Value = i + 1;
                worksheet.Cell(row, 1).Style.Alignment.SetHorizontal(XLAlignmentHorizontalValues.Center);
                worksheet.Cell(row, 2).Value = student.Hoten;
                worksheet.Cell(row, 3).Value = student.Id;
                worksheet.Cell(row, 4).Value = student.Email;
                worksheet.Cell(row, 5).Value = student.Gioitinh.HasValue ? (student.Gioitinh.Value ? "Nam" : "Nữ") : "N/A";
                worksheet.Cell(row, 6).Value = student.Ngaysinh?.ToString("dd/MM/yyyy") ?? "N/A";
                worksheet.Cell(row, 7).Value = student.PhoneNumber;
            }

            worksheet.Columns().AdjustToContents();

            using var stream = new MemoryStream();
            workbook.SaveAs(stream);
            return stream.ToArray();
        }

        public async Task<ImportStudentDTO> ImportStudentsFromExcelAsync(int lopId, Stream excelFileStream, string currentUserId)
        {
            var result = new ImportStudentDTO();

            var lop = await _context.Lops.FirstOrDefaultAsync(l => l.Malop == lopId);
            if (lop == null)
            {
                result.Errors.Add("Không tìm thấy lớp học.");
                return result;
            }

            using var workbook = new XLWorkbook(excelFileStream);
            var worksheet = workbook.Worksheet(1);
            IXLRow headerRow = null;
            foreach (var row in worksheet.RowsUsed())
            {
                if (row.CellsUsed().Any(c => c.Value.ToString().Trim().Equals("MSSV", StringComparison.OrdinalIgnoreCase)))
                {
                    headerRow = row;
                    break;
                }
            }
            if (headerRow == null)
            {
                result.Errors.Add("Không tìm thấy dòng tiêu đề chứa MSSV.");
                return result;
            }

            int headerRowNum = headerRow.RowNumber();
            var lastRowUsed = worksheet.LastRowUsed();

            var mssvCol = headerRow.CellsUsed().FirstOrDefault(c => c.Value.ToString().Trim().Equals("MSSV", StringComparison.OrdinalIgnoreCase))?.Address.ColumnNumber;
            var hotenCol = headerRow.CellsUsed().FirstOrDefault(c => c.Value.ToString().Trim().Equals("Họ tên", StringComparison.OrdinalIgnoreCase))?.Address.ColumnNumber;
            var emailCol = headerRow.CellsUsed().FirstOrDefault(c => c.Value.ToString().Trim().Equals("Email", StringComparison.OrdinalIgnoreCase))?.Address.ColumnNumber;
            var ngaysinhCol = headerRow.CellsUsed().FirstOrDefault(c => c.Value.ToString().Trim().Equals("Ngày sinh (dd/MM/yyyy)", StringComparison.OrdinalIgnoreCase))?.Address.ColumnNumber;
            var gioitinhCol = headerRow.CellsUsed().FirstOrDefault(c => c.Value.ToString().Trim().Equals("Giới tính (Nam/Nữ)", StringComparison.OrdinalIgnoreCase))?.Address.ColumnNumber;
            var sdtCol = headerRow.CellsUsed().FirstOrDefault(c => c.Value.ToString().Trim().Equals("Số điện thoại", StringComparison.OrdinalIgnoreCase))?.Address.ColumnNumber;

            if (mssvCol == null || hotenCol == null || emailCol == null)
            {
                result.Errors.Add("File Excel thiếu các cột bắt buộc: MSSV, Họ tên, Email.");
                return result;
            }

            for (int rowNum = headerRowNum + 1; rowNum <= lastRowUsed.RowNumber(); rowNum++)
            {
                var row = worksheet.Row(rowNum);
                if (row.IsEmpty()) continue;

                result.TongSo++;

                string mssv = row.Cell(mssvCol.Value).GetValue<string>().Trim();
                string hoten = row.Cell(hotenCol.Value).GetValue<string>().Trim();
                string email = row.Cell(emailCol.Value).GetValue<string>().Trim();
                DateTime? ngaysinh = null;
                bool? gioitinh = null;
                string? phoneNumber = null;

                if (string.IsNullOrWhiteSpace(mssv) || string.IsNullOrWhiteSpace(hoten) || string.IsNullOrWhiteSpace(email))
                {
                    result.Errors.Add($"Dòng {rowNum}: Thiếu thông tin MSSV, Họ tên hoặc Email. Bỏ qua.");
                    continue;
                }

                if (ngaysinhCol.HasValue && !string.IsNullOrWhiteSpace(row.Cell(ngaysinhCol.Value).GetValue<string>()))
                {
                    if (DateTime.TryParseExact(row.Cell(ngaysinhCol.Value).GetValue<string>(), "dd/MM/yyyy", System.Globalization.CultureInfo.InvariantCulture, System.Globalization.DateTimeStyles.None, out DateTime parsedDate))
                    {
                        ngaysinh = parsedDate;
                    }
                    else
                    {
                        result.Warnings.Add($"Dòng {rowNum}: Định dạng Ngày sinh không hợp lệ (phải là dd/MM/yyyy). Bỏ qua giá trị này.");
                    }
                }

                if (gioitinhCol.HasValue && !string.IsNullOrWhiteSpace(row.Cell(gioitinhCol.Value).GetValue<string>()))
                {
                    string genderStr = row.Cell(gioitinhCol.Value).GetValue<string>().Trim().ToLower();
                    if (genderStr == "nam")
                    {
                        gioitinh = true;
                    }
                    else if (genderStr == "nữ" || genderStr == "nu")
                    {
                        gioitinh = false;
                    }
                    else
                    {
                        result.Warnings.Add($"Dòng {rowNum}: Giá trị Giới tính không hợp lệ (phải là 'Nam' hoặc 'Nữ'). Bỏ qua giá trị này.");
                    }
                }

                if (sdtCol.HasValue)
                {
                    phoneNumber = row.Cell(sdtCol.Value).GetValue<string>().Trim();
                }

                var existingUser = await _context.NguoiDungs.FirstOrDefaultAsync(u => u.Id == mssv);
                var alreadyInClass = await _context.ChiTietLops.AnyAsync(ctl => ctl.Malop == lopId && ctl.Manguoidung == mssv);

                if (alreadyInClass)
                {
                    result.Warnings.Add($"Dòng {rowNum}: Sinh viên {hoten} ({mssv}) đã có trong lớp. Bỏ qua.");
                    continue;
                }

                if (existingUser != null)
                {
                    var chiTietLop = new ChiTietLop
                    {
                        Malop = lopId,
                        Manguoidung = existingUser.Id,
                        Trangthai = true
                    };
                    await _context.ChiTietLops.AddAsync(chiTietLop);
                    result.SoHocSinhThemVaoLop++;
                }
                else
                {
                    var newUser = new NguoiDung
                    {
                        Id = mssv,
                        Hoten = hoten,
                        Email = email,
                        Ngaysinh = ngaysinh,
                        Gioitinh = gioitinh,
                        PhoneNumber = phoneNumber,
                        UserName = mssv,
                        PasswordHash = Guid.NewGuid().ToString(),
                        Trangthai = true,
                        Hienthi = true
                    };

                    var createResult = await _userManager.CreateAsync(newUser, newUser.PasswordHash);
                    if (!createResult.Succeeded)
                    {
                        result.Errors.Add($"Dòng {rowNum}: Không thể tạo người dùng {mssv}: {string.Join(", ", createResult.Errors.Select(e => e.Description))}");
                        continue;
                    }

                    await _userManager.AddToRoleAsync(newUser, "student");

                    result.SoHocSinhTaoTKMoi++;

                    var chiTietLop = new ChiTietLop
                    {
                        Malop = lopId,
                        Manguoidung = newUser.Id,
                        Trangthai = true
                    };
                    await _context.ChiTietLops.AddAsync(chiTietLop);
                    result.SoHocSinhTaoTKMoi++;
                }
            }
            await _context.SaveChangesAsync();
            return result;
        }
    }
}
