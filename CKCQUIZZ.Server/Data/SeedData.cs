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

                // Thêm các teachers còn thiếu
                var teacher3Result = await _userManager.CreateAsync(new NguoiDung
                {
                    Id = "teacher003",
                    UserName = "teacher3",
                    Hoten = "Thầy Nguyễn Văn C",
                    Email = "teacher3@caothang.edu.vn",
                    Gioitinh = true,
                    Ngaysinh = new DateTime(1985, 5, 12),
                    Avatar = null,
                    Ngaythamgia = DateTime.Today,
                    PhoneNumber = "5672849104",
                    Trangthai = true,
                }, "Giaovien123@");

                if (teacher3Result.Succeeded)
                {
                    var teacher3 = await _userManager.FindByNameAsync("teacher3");
                    await _userManager.AddToRoleAsync(teacher3 ?? default!, TeacherRoleName);
                }

                var teacher4Result = await _userManager.CreateAsync(new NguoiDung
                {
                    Id = "teacher004",
                    UserName = "teacher4",
                    Hoten = "Thầy Nguyễn Văn D",
                    Email = "teacher4@caothang.edu.vn",
                    Gioitinh = true,
                    Ngaysinh = new DateTime(1985, 5, 12),
                    Avatar = null,
                    Ngaythamgia = DateTime.Today,
                    PhoneNumber = "5672849105",
                    Trangthai = true,
                }, "Giaovien123@");

                if (teacher4Result.Succeeded)
                {
                    var teacher4 = await _userManager.FindByNameAsync("teacher4");
                    await _userManager.AddToRoleAsync(teacher4 ?? default!, TeacherRoleName);
                }

                var teacher5Result = await _userManager.CreateAsync(new NguoiDung
                {
                    Id = "teacher005",
                    UserName = "teacher5",
                    Hoten = "Thầy Nguyễn Văn E",
                    Email = "teacher5@caothang.edu.vn",
                    Gioitinh = true,
                    Ngaysinh = new DateTime(1985, 5, 12),
                    Avatar = null,
                    Ngaythamgia = DateTime.Today,
                    PhoneNumber = "5672849106",
                    Trangthai = true,
                }, "Giaovien123@");

                if (teacher5Result.Succeeded)
                {
                    var teacher5 = await _userManager.FindByNameAsync("teacher5");
                    await _userManager.AddToRoleAsync(teacher5 ?? default!, TeacherRoleName);
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



                var teacherFullAccessFunctions = new[] { "hocphan", "monhoc", "thongbao", "chuong", "dethi", "nguoidung"};
                foreach (var func in teacherFullAccessFunctions)
                {
                    foreach (var action in allActions)
                    {
                        permissions.Add(new ChiTietQuyen { RoleId = teacherRole.Id, ChucNang = func, HanhDong = action });
                    }
                }
                permissions.Add(new ChiTietQuyen { RoleId = teacherRole.Id, ChucNang = "thamgiahocphan", HanhDong = "join" });


                var studentViewFunctions = new[] { "hocphan", "thongbao", "dethi" };
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
            if (!await _context.MonHocs.AnyAsync())
            {
                #region Seed MonHoc Data
                var monHocs = new List<MonHoc>
                {
                    new() { Mamonhoc = 734846, Tenmonhoc = "Lập trình C#", Sotinchi = 3, Sotietlythuyet = 45, Sotietthuchanh = 30, Trangthai = true },
                    new() { Mamonhoc = 227095, Tenmonhoc = "Cấu trúc dữ liệu & Giải thuật", Sotinchi = 3, Sotietlythuyet = 45, Sotietthuchanh = 30, Trangthai = true },
                    new() { Mamonhoc = 460154, Tenmonhoc = "Cơ sở dữ liệu", Sotinchi = 3, Sotietlythuyet = 45, Sotietthuchanh = 15, Trangthai = true },
                    new() { Mamonhoc = 645403, Tenmonhoc = "Mạng máy tính", Sotinchi = 3, Sotietlythuyet = 45, Sotietthuchanh = 15, Trangthai = true },
                    new() { Mamonhoc = 732237, Tenmonhoc = "Hệ điều hành", Sotinchi = 3, Sotietlythuyet = 45, Sotietthuchanh = 0, Trangthai = true },
                    new() { Mamonhoc = 570488, Tenmonhoc = "Toán cao cấp A1", Sotinchi = 4, Sotietlythuyet = 60, Sotietthuchanh = 0, Trangthai = true },
                    new() { Mamonhoc = 673119, Tenmonhoc = "Vật lý đại cương 1", Sotinchi = 3, Sotietlythuyet = 45, Sotietthuchanh = 0, Trangthai = true }
                };
                await _context.MonHocs.AddRangeAsync(monHocs);
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
                var lops = new List<Lop>
                {
                    new() { Tenlop = "Lập trình C++ - Lớp A", Mamoi = "CPP2024A", Siso = 30, Ghichu = "Lớp học lập trình C++ cơ bản", Namhoc = 2024, Hocky = 1, Trangthai = true, Hienthi = true, Giangvien = "teacher001" },
                    new() { Tenlop = "Java Programming - Lớp B", Mamoi = "JAVA2024B", Siso = 25, Ghichu = "Lớp học Java nâng cao", Namhoc = 2024, Hocky = 1, Trangthai = true, Hienthi = true, Giangvien = "teacher001" },
                    new() { Tenlop = "C# Development - Lớp A", Mamoi = "CSHARP2024A", Siso = 28, Ghichu = "Lớp học C# và .NET", Namhoc = 2024, Hocky = 1, Trangthai = true, Hienthi = true, Giangvien = "teacher002" },
                    new() { Tenlop = "Python Programming - Lớp A", Mamoi = "PYTHON2024A", Siso = 32, Ghichu = "Lớp học Python cơ bản", Namhoc = 2024, Hocky = 1, Trangthai = true, Hienthi = true, Giangvien = "teacher003" },
                    new() { Tenlop = "Database Systems - Lớp A", Mamoi = "DB2024A", Siso = 26, Ghichu = "Lớp học cơ sở dữ liệu", Namhoc = 2024, Hocky = 2, Trangthai = true, Hienthi = true, Giangvien = "teacher003" },
                    new() { Tenlop = "Computer Networks - Lớp A", Mamoi = "NET2024A", Siso = 24, Ghichu = "Lớp học mạng máy tính", Namhoc = 2024, Hocky = 2, Trangthai = true, Hienthi = true, Giangvien = "teacher004" },
                    new() { Tenlop = "Software Engineering - Lớp A", Mamoi = "SE2024A", Siso = 22, Ghichu = "Lớp học kỹ thuật phần mềm", Namhoc = 2024, Hocky = 2, Trangthai = true, Hienthi = true, Giangvien = "teacher004" },
                    new() { Tenlop = "Data Structures - Lớp A", Mamoi = "DS2024A", Siso = 30, Ghichu = "Lớp học cấu trúc dữ liệu", Namhoc = 2024, Hocky = 2, Trangthai = true, Hienthi = true, Giangvien = "teacher002" }
                };
                await _context.Lops.AddRangeAsync(lops);
                await _context.SaveChangesAsync();
            }
            #endregion

            // Tạm thời bỏ qua ChiTietLop vì cần ID tự động từ Lop

            #region CauHoi
            if (!await _context.CauHois.AnyAsync())
            {
                var lopIds = await _context.Lops.Select(l => l.Malop).ToListAsync();
                var monHocIds = await _context.MonHocs.Select(m => m.Mamonhoc).ToListAsync();

                if (lopIds.Count == 0 || monHocIds.Count == 0)
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

            // Tạm thời bỏ qua KetQua và ChiTietKetQua vì cần ID tự động

            await _context.SaveChangesAsync();
        }
    }
}