using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using CKCQUIZZ.Server.Models;
using Microsoft.AspNetCore.Identity;
using Microsoft.EntityFrameworkCore;

namespace CKCQUIZZ.Server.Data
{
    public class SeedData(CkcquizzContext _context, UserManager<NguoiDung> _userManager, RoleManager<ApplicationRole> _roleManager)
    {

        private readonly string AdminRoleName = "Admin";
        private readonly string StudentRoleName = "Student";
        private readonly string TeacherRoleName = "Teacher";

        public async Task Seed()
        {
            var random = new Random();

            #region Quyen

            if (!await _roleManager.Roles.AnyAsync())
            {
                await _roleManager.CreateAsync(new ApplicationRole
                {
                    Name = AdminRoleName,
                    NormalizedName = AdminRoleName.ToUpper(),
                    TrangThai = true
                });
                await _roleManager.CreateAsync(new ApplicationRole
                {
                    Name = TeacherRoleName,
                    NormalizedName = TeacherRoleName.ToUpper(),
                    TrangThai = true,
                    ThamGiaHocPhan = true


                });
                await _roleManager.CreateAsync(new ApplicationRole
                {
                    Name = StudentRoleName,
                    NormalizedName = StudentRoleName.ToUpper(),
                    TrangThai = true,
                    ThamGiaThi = true,
                    ThamGiaHocPhan = true
                });
            }
            #endregion Quyen

            #region NguoiDung

            if (!await _userManager.Users.AnyAsync())
            {

                var result = await _userManager.CreateAsync(new NguoiDung
                {
                    Id = "0306221378",
                    UserName = "Admin",
                    Hoten = "Ngọc Thông",
                    Email = "0306221378@caothang.edu.vn",
                    Gioitinh = true,
                    Ngaysinh = new DateTime(2004, 01, 31),
                    Avatar = null,
                    Ngaythamgia = DateTime.Today,
                    PhoneNumber = "1234567890",
                    Trangthai = true,
                }, "Thongle789321@");
                if (result.Succeeded)
                {
                    var user = await _userManager.FindByNameAsync("Admin");
                    await _userManager.AddToRoleAsync(user ?? default!, AdminRoleName);
                }
                var teacherResult = await _userManager.CreateAsync(new NguoiDung
                {
                    Id = "teacher001",
                    UserName = "teacher1",
                    Hoten = "Thầy Nguyễn Văn A",
                    Email = "teacher1@caothang.edu.vn",
                    Gioitinh = true,
                    Ngaysinh = new DateTime(1985, 5, 12),
                    Avatar = null,
                    Ngaythamgia = DateTime.Today,
                    PhoneNumber = "5672849102",
                    Trangthai = true,
                }, "Giaovien123@");

                if (teacherResult.Succeeded)
                {
                    var teacher = await _userManager.FindByNameAsync("teacher1");
                    await _userManager.AddToRoleAsync(teacher ?? default!, TeacherRoleName);
                }

                var student1Result = await _userManager.CreateAsync(new NguoiDung
                {
                    Id = "student001",
                    UserName = "student1",
                    Hoten = "Trần Văn B",
                    Email = "student1@caothang.edu.vn",
                    Gioitinh = false,
                    Ngaysinh = new DateTime(2006, 3, 14),
                    Avatar = null,
                    Ngaythamgia = DateTime.Today,
                    PhoneNumber = "2401495012",
                    Trangthai = true,
                }, "Hocsinh123@");

                if (student1Result.Succeeded)
                {
                    var student1 = await _userManager.FindByNameAsync("student1");
                    await _userManager.AddToRoleAsync(student1 ?? default!, StudentRoleName);
                }
                var teacherResult2 = await _userManager.CreateAsync(new NguoiDung
                {
                    Id = "teacher002",
                    UserName = "teacher2",
                    Hoten = "Thầy Nguyễn Văn B",
                    Email = "teacher2@caothang.edu.vn",
                    Gioitinh = true,
                    Ngaysinh = new DateTime(1985, 5, 12),
                    Avatar = null,
                    Ngaythamgia = DateTime.Today,
                    PhoneNumber = "5672849103",
                    Trangthai = true,
                }, "Giaovien123@");

                if (teacherResult2.Succeeded)
                {
                    var teacher = await _userManager.FindByNameAsync("teacher2");
                    await _userManager.AddToRoleAsync(teacher ?? default!, TeacherRoleName);
                }

                var student2Result = await _userManager.CreateAsync(new NguoiDung
                {
                    Id = "student002",
                    UserName = "student2",
                    Hoten = "Trần Văn C",
                    Email = "student2@caothang.edu.vn",
                    Gioitinh = false,
                    Ngaysinh = new DateTime(2006, 3, 14),
                    Avatar = null,
                    Ngaythamgia = DateTime.Today,
                    PhoneNumber = "2401495013",
                    Trangthai = true,
                }, "Hocsinh123@");

                if (student2Result.Succeeded)
                {
                    var student2 = await _userManager.FindByNameAsync("student2");
                    await _userManager.AddToRoleAsync(student2 ?? default!, StudentRoleName);
                }
                var student3Result = await _userManager.CreateAsync(new NguoiDung
                {
                    Id = "student003",
                    UserName = "student3",
                    Hoten = "Trần Văn D",
                    Email = "student3@caothang.edu.vn",
                    Gioitinh = false,
                    Ngaysinh = new DateTime(2006, 3, 14),
                    Avatar = null,
                    Ngaythamgia = DateTime.Today,
                    PhoneNumber = "2401495015",
                    Trangthai = true,
                }, "Hocsinh123@");

                if (student3Result.Succeeded)
                {
                    var student3 = await _userManager.FindByNameAsync("student3");
                    await _userManager.AddToRoleAsync(student3 ?? default!, StudentRoleName);
                }
                var student4Result = await _userManager.CreateAsync(new NguoiDung
                {
                    Id = "student004",
                    UserName = "student4",
                    Hoten = "Trần Văn E",
                    Email = "student4@caothang.edu.vn",
                    Gioitinh = false,
                    Ngaysinh = new DateTime(2006, 3, 14),
                    Avatar = null,
                    Ngaythamgia = DateTime.Today,
                    PhoneNumber = "2401495011",
                    Trangthai = true,
                }, "Hocsinh123@");

                if (student4Result.Succeeded)
                {
                    var student4 = await _userManager.FindByNameAsync("student4");
                    await _userManager.AddToRoleAsync(student4 ?? default!, StudentRoleName);
                }
                var student5Result = await _userManager.CreateAsync(new NguoiDung
                {
                    Id = "student005",
                    UserName = "student5",
                    Hoten = "Trần Văn X",
                    Email = "student4@caothang.edu.vn",
                    Gioitinh = false,
                    Ngaysinh = new DateTime(2006, 3, 14),
                    Avatar = null,
                    Ngaythamgia = DateTime.Today,
                    PhoneNumber = "2401495011",
                    Trangthai = true,
                }, "Hocsinh123@");

                if (student5Result.Succeeded)
                {
                    var student5 = await _userManager.FindByNameAsync("student5");
                    await _userManager.AddToRoleAsync(student5 ?? default!, StudentRoleName);
                }
                var student6Result = await _userManager.CreateAsync(new NguoiDung
                {
                    Id = "student006",
                    UserName = "student6",
                    Hoten = "Trần Văn M",
                    Email = "student5@caothang.edu.vn",
                    Gioitinh = false,
                    Ngaysinh = new DateTime(2006, 3, 14),
                    Avatar = null,
                    Ngaythamgia = DateTime.Today,
                    PhoneNumber = "2401495018",
                    Trangthai = true,
                }, "Hocsinh123@");

                if (student6Result.Succeeded)
                {
                    var student6 = await _userManager.FindByNameAsync("student6");
                    await _userManager.AddToRoleAsync(student6 ?? default!, StudentRoleName);
                }
                var student7Result = await _userManager.CreateAsync(new NguoiDung
                {
                    Id = "student007",
                    UserName = "student7",
                    Hoten = "Trần Văn P",
                    Email = "student5@caothang.edu.vn",
                    Gioitinh = false,
                    Ngaysinh = new DateTime(2006, 3, 14),
                    Avatar = null,
                    Ngaythamgia = DateTime.Today,
                    PhoneNumber = "2401495014",
                    Trangthai = true,
                }, "Hocsinh123@");

                if (student7Result.Succeeded)
                {
                    var student7 = await _userManager.FindByNameAsync("student7");
                    await _userManager.AddToRoleAsync(student7 ?? default!, StudentRoleName);
                }
                var student8Result = await _userManager.CreateAsync(new NguoiDung
                {
                    Id = "student008",
                    UserName = "student8",
                    Hoten = "Trần Văn E",
                    Email = "student8@caothang.edu.vn",
                    Gioitinh = false,
                    Ngaysinh = new DateTime(2006, 3, 14),
                    Avatar = null,
                    Ngaythamgia = DateTime.Today,
                    PhoneNumber = "2401495012",
                    Trangthai = true,
                }, "Hocsinh123@");

                if (student8Result.Succeeded)
                {
                    var student8 = await _userManager.FindByNameAsync("student8");
                    await _userManager.AddToRoleAsync(student8 ?? default!, StudentRoleName);
                }
            }

            #endregion NguoiDung

            #region DanhMucChucNang

            if (!await _context.DanhMucChucNangs.AnyAsync())
            {
                var functions = new List<DanhMucChucNang>
                {
                    new() { ChucNang = "nguoidung", TenChucNang = "Quản lý người dùng" },
                    new() { ChucNang = "hocphan", TenChucNang = "Quản lý học phần" },
                    new() { ChucNang = "cauhoi", TenChucNang = "Quản lý câu hỏi" },
                    new() { ChucNang = "monhoc", TenChucNang = "Quản lý môn học" },
                    new() { ChucNang = "chuong", TenChucNang = "Quản lý chương" },
                    new() { ChucNang = "dethi", TenChucNang = "Quản lý đề thi" },
                    new() { ChucNang = "phancong", TenChucNang = "Quản lý phân công"},
                    new() { ChucNang = "nhomquyen", TenChucNang = "Quản lý nhóm quyền" },
                    new() { ChucNang = "thongbao", TenChucNang = "Quản lý thông báo" },
                    new() { ChucNang = "thamgiahocphan", TenChucNang = "Tham gia học phần" },
                    new() { ChucNang = "thamgiathi", TenChucNang = "Tham gia thi" },


                };
                await _context.DanhMucChucNangs.AddRangeAsync(functions);
                await _context.SaveChangesAsync();
            }
            #endregion
            if (!await _context.ChiTietQuyens.AnyAsync())
            {
                var adminRole = await _roleManager.FindByNameAsync(AdminRoleName);
                var teacherRole = await _roleManager.FindByNameAsync(TeacherRoleName);
                var studentRole = await _roleManager.FindByNameAsync(StudentRoleName);

                if (adminRole == null || teacherRole == null || studentRole == null) return;

                var allManagementFunctions = await _context.DanhMucChucNangs
                    .Where(f => f.ChucNang != "thamgiahocphan" && f.ChucNang != "thamgiathi")
                    .Select(f => f.ChucNang)
                    .ToListAsync();

                var allActions = new[] { "view", "create", "update", "delete" };
                var viewOnlyAction = new[] { "view" };

                var permissions = new List<ChiTietQuyen>();

                foreach (var func in allManagementFunctions)
                {
                    foreach (var action in allActions)
                    {
                        permissions.Add(new ChiTietQuyen { RoleId = adminRole.Id, ChucNang = func, HanhDong = action });
                    }
                }



                var teacherFullAccessFunctions = new[] { "hocphan", "monhoc", "thongbao" };
                foreach (var func in teacherFullAccessFunctions)
                {
                    foreach (var action in allActions)
                    {
                        permissions.Add(new ChiTietQuyen { RoleId = teacherRole.Id, ChucNang = func, HanhDong = action });
                    }
                }
                permissions.Add(new ChiTietQuyen { RoleId = teacherRole.Id, ChucNang = "thamgiahocphan", HanhDong = "join" });


                var studentViewFunctions = new[] { "hocphan", "cauhoi", "monhoc", "chuong", "thongbao", "dethi" };
                foreach (var func in studentViewFunctions)
                {
                    foreach (var action in viewOnlyAction)
                    {
                        permissions.Add(new ChiTietQuyen { RoleId = studentRole.Id, ChucNang = func, HanhDong = action });
                    }
                }
                permissions.Add(new ChiTietQuyen { RoleId = studentRole.Id, ChucNang = "thamgiahocphan", HanhDong = "join" });
                permissions.Add(new ChiTietQuyen { RoleId = studentRole.Id, ChucNang = "thamgiathi", HanhDong = "join" });

                await _context.ChiTietQuyens.AddRangeAsync(permissions);
                await _context.SaveChangesAsync();
            }

            #region Structured Seeding Data
            var structuredData = new List<(string MonHoc, string Chuong, string CauHoi, string LoaiCauHoi, List<string> CauTraLoi, int DapAnDungIndex)>
            {
                ("Lập Trình Căn Bản", "Biến và Kiểu dữ liệu", "Trong C#, từ khóa nào dùng để khai báo một lớp?", "single_choice",
                    new List<string> { "class", "struct", "interface", "enum" }, 0),
                ("Lập Trình Căn Bản", "Cấu trúc điều khiển", "Đâu không phải là một loại vòng lặp trong C#?", "single_choice",
                    new List<string> { "for", "while", "do-while", "repeat-until" }, 3),
                ("Cấu Trúc Dữ Liệu & Giải Thuật", "Cấu trúc dữ liệu tuyến tính", "Cấu trúc dữ liệu nào hoạt động theo nguyên tắc FIFO?", "single_choice",
                    new List<string> { "Queue", "Stack", "Linked List", "Tree" }, 0),
                ("Cấu Trúc Dữ Liệu & Giải Thuật", "Thuật toán sắp xếp", "Thuật toán sắp xếp nào có độ phức tạp O(n log n) trong trường hợp xấu nhất?", "single_choice",
                    new List<string> { "Merge Sort", "Bubble Sort", "Insertion Sort", "Selection Sort" }, 0),
                ("Cơ Sở Dữ Liệu", "Ngôn ngữ SQL", "Trong SQL, câu lệnh nào dùng để lấy dữ liệu từ một bảng?", "single_choice",
                    new List<string> { "SELECT", "INSERT", "UPDATE", "DELETE" }, 0),
                ("Mạng Máy Tính", "Giao thức ứng dụng", "Giao thức nào được sử dụng để gửi email?", "single_choice",
                    new List<string> { "SMTP", "HTTP", "FTP", "TCP" }, 0),
                ("Hệ Điều Hành", "Tổng quan Hệ điều hành", "Hệ điều hành nào là mã nguồn mở?", "single_choice",
                    new List<string> { "Linux", "Windows", "macOS", "iOS" }, 0),
                ("Lập Trình Căn Bản", "Tổng quan", "Ngôn ngữ lập trình C# được phát triển bởi công ty nào?", "essay",
                    new List<string> { "Microsoft" }, 0),
                ("Toán Cao Cấp A1", "Giới thiệu về Đại số tuyến tính", "Ma trận đơn vị là gì?", "essay",
                    new List<string> { "Là ma trận vuông có các phần tử trên đường chéo chính bằng 1 và các phần tử còn lại bằng 0." }, 0),
                ("Vật Lý Đại Cương 1", "Động lực học chất điểm", "Phát biểu Định luật II Newton.", "essay",
                    new List<string> { "Gia tốc của một vật cùng hướng với lực tác dụng lên vật. Độ lớn của gia tốc tỉ lệ thuận với độ lớn của lực và tỉ lệ nghịch với khối lượng của vật." }, 0)
            };
            #endregion

            #region Seed MonHoc, Chuong, CauHoi, CauTraLoi
            if (!await _context.MonHocs.AnyAsync())
            {
                var teacherIds = new List<string> { "teacher001", "teacher002" };
                var monHocIdMap = new Dictionary<string, int>();

                var monHocNames = structuredData.Select(d => d.MonHoc).Distinct().ToList();
                var monHocsToCreate = new List<MonHoc>();
                foreach (var name in monHocNames)
                {
                    int newId = random.Next(100000, 1000000);
                    while (monHocIdMap.ContainsValue(newId))
                    {
                        newId = random.Next(100000, 1000000);
                    }
                    monHocIdMap[name] = newId;
                    monHocsToCreate.Add(new MonHoc
                    {
                        Mamonhoc = newId,
                        Tenmonhoc = name,
                        Sotinchi = random.Next(2, 5),
                        Sotietlythuyet = random.Next(30, 61),
                        Sotietthuchanh = random.Next(15, 46),
                        Trangthai = true
                    });
                }
                await _context.MonHocs.AddRangeAsync(monHocsToCreate);
                await _context.SaveChangesAsync();


                var chuongMap = new Dictionary<string, Chuong>();

                foreach (var data in structuredData)
                {
                    Chuong currentChuong;
                    var chuongKey = $"{data.MonHoc}_{data.Chuong}";

                    if (!chuongMap.ContainsKey(chuongKey))
                    {
                        currentChuong = new Chuong
                        {
                            Tenchuong = data.Chuong,
                            Mamonhoc = monHocIdMap[data.MonHoc],
                            Nguoitao = teacherIds[random.Next(teacherIds.Count)],
                            Trangthai = true
                        };
                        _context.Chuongs.Add(currentChuong);
                        await _context.SaveChangesAsync();
                        chuongMap[chuongKey] = currentChuong;
                    }
                    else
                    {
                        currentChuong = chuongMap[chuongKey];
                    }

                    var newCauHoi = new CauHoi
                    {
                        Noidung = data.CauHoi,
                        Loaicauhoi = data.LoaiCauHoi,
                        Dokho = random.Next(1, 4),
                        Machuong = currentChuong.Machuong,
                        Mamonhoc = currentChuong.Mamonhoc,
                        Nguoitao = teacherIds[random.Next(teacherIds.Count)],
                        Trangthai = true
                    };
                    _context.CauHois.Add(newCauHoi);
                    await _context.SaveChangesAsync();

                    for (int i = 0; i < data.CauTraLoi.Count; i++)
                    {
                        var newCauTraLoi = new CauTraLoi
                        {
                            Macauhoi = newCauHoi.Macauhoi,
                            Noidungtl = data.CauTraLoi[i],
                            Dapan = (i == data.DapAnDungIndex)
                        };
                        _context.CauTraLois.Add(newCauTraLoi);
                    }
                }
                await _context.SaveChangesAsync();
            }
            #endregion

            #region Lop
            if (!await _context.Lops.AnyAsync())
            {
                var lopNames = new[] { "DHCNTT16A", "DHCNTT16B", "DHCNTT17A", "DHCNTT17B", "DHCNTT18A", "DHCNTT18B", "DHCNTT19A", "DHCNTT19B", "DHCNTT20A", "DHCNTT20B" };
                var lops = new List<Lop>();
                var teacherIds = new List<string> { "teacher001", "teacher002" };
                for (int i = 0; i < 10; i++)
                {
                    lops.Add(new Lop
                    {
                        Tenlop = lopNames[i],
                        Giangvien = teacherIds[random.Next(teacherIds.Count)],
                        Mamoi = Guid.NewGuid().ToString().Substring(0, 8).ToUpper(),
                        Hocky = random.Next(1, 3),
                        Namhoc = random.Next(2023, 2026),
                        Siso = random.Next(20, 50),
                        Ghichu = $"Lớp học phần {lopNames[i]}",
                        Hienthi = true,
                        Trangthai = true
                    });
                }
                await _context.Lops.AddRangeAsync(lops);
                await _context.SaveChangesAsync();
            }
            #endregion
            #region DanhSachLop
            if (!await _context.DanhSachLops.AnyAsync())
            {
                var lopIds = await _context.Lops.Select(l => l.Malop).ToListAsync();
                var monHocIds = await _context.MonHocs.Select(m => m.Mamonhoc).ToListAsync();

                if (!lopIds.Any() || !monHocIds.Any())
                {
                    return;
                }

                var danhSachLops = new List<DanhSachLop>();

                foreach (var lopId in lopIds)
                {
                    var randomMonHocId = monHocIds[random.Next(monHocIds.Count)];

                    danhSachLops.Add(new DanhSachLop
                    {
                        Malop = lopId,
                        Mamonhoc = randomMonHocId
                    });
                }

                await _context.DanhSachLops.AddRangeAsync(danhSachLops);
                await _context.SaveChangesAsync();
            }
            #endregion
            await _context.SaveChangesAsync();
        }
    }
}