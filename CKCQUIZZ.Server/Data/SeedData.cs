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

                // Thêm Admin phụ
                var admin2Result = await _userManager.CreateAsync(new NguoiDung
                {
                    Id = "admin002",
                    UserName = "admin2",
                    Hoten = "Nguyễn Thị Lan",
                    Email = "admin2@caothang.edu.vn",
                    Gioitinh = false,
                    Ngaysinh = new DateTime(1985, 8, 15),
                    Avatar = null,
                    Ngaythamgia = DateTime.Today,
                    PhoneNumber = "0987654321",
                    Trangthai = true,
                }, "Admin123@");

                if (admin2Result.Succeeded)
                {
                    var admin2 = await _userManager.FindByNameAsync("admin2");
                    await _userManager.AddToRoleAsync(admin2 ?? default!, AdminRoleName);
                }

                // Thêm các giảng viên bổ sung
                var teacher3Result = await _userManager.CreateAsync(new NguoiDung
                {
                    Id = "teacher003",
                    UserName = "teacher3",
                    Hoten = "Lê Văn Minh",
                    Email = "teacher3@caothang.edu.vn",
                    Gioitinh = true,
                    Ngaysinh = new DateTime(1980, 12, 20),
                    Avatar = null,
                    Ngaythamgia = DateTime.Today,
                    PhoneNumber = "0912345678",
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
                    Hoten = "Phạm Thị Hoa",
                    Email = "teacher4@caothang.edu.vn",
                    Gioitinh = false,
                    Ngaysinh = new DateTime(1988, 6, 10),
                    Avatar = null,
                    Ngaythamgia = DateTime.Today,
                    PhoneNumber = "0923456789",
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
                    Hoten = "Hoàng Văn Đức",
                    Email = "teacher5@caothang.edu.vn",
                    Gioitinh = true,
                    Ngaysinh = new DateTime(1983, 4, 25),
                    Avatar = null,
                    Ngaythamgia = DateTime.Today,
                    PhoneNumber = "0934567890",
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

            #region MonHoc
            if (!await _context.MonHocs.AnyAsync())
            {
                var monHocs = new List<MonHoc>
                {
                    new() { Mamonhoc = 1, Tenmonhoc = "Lập trình C/C++", Sotinchi = 3, Sotietlythuyet = 30, Sotietthuchanh = 30, Trangthai = true },
                    new() { Mamonhoc = 2, Tenmonhoc = "Lập trình Java", Sotinchi = 4, Sotietlythuyet = 45, Sotietthuchanh = 30, Trangthai = true },
                    new() { Mamonhoc = 3, Tenmonhoc = "Lập trình C#", Sotinchi = 4, Sotietlythuyet = 45, Sotietthuchanh = 30, Trangthai = true },
                    new() { Mamonhoc = 4, Tenmonhoc = "Lập trình Python", Sotinchi = 3, Sotietlythuyet = 30, Sotietthuchanh = 30, Trangthai = true },
                    new() { Mamonhoc = 5, Tenmonhoc = "Cơ sở dữ liệu", Sotinchi = 4, Sotietlythuyet = 45, Sotietthuchanh = 30, Trangthai = true },
                    new() { Mamonhoc = 6, Tenmonhoc = "Mạng máy tính", Sotinchi = 3, Sotietlythuyet = 30, Sotietthuchanh = 30, Trangthai = true },
                    new() { Mamonhoc = 7, Tenmonhoc = "Kỹ thuật phần mềm", Sotinchi = 3, Sotietlythuyet = 45, Sotietthuchanh = 15, Trangthai = true },
                    new() { Mamonhoc = 8, Tenmonhoc = "Toán rời rạc", Sotinchi = 3, Sotietlythuyet = 45, Sotietthuchanh = 0, Trangthai = true },
                    new() { Mamonhoc = 9, Tenmonhoc = "Cấu trúc dữ liệu và giải thuật", Sotinchi = 4, Sotietlythuyet = 45, Sotietthuchanh = 30, Trangthai = true },
                    new() { Mamonhoc = 10, Tenmonhoc = "Hệ điều hành", Sotinchi = 3, Sotietlythuyet = 30, Sotietthuchanh = 30, Trangthai = true }
                };
                await _context.MonHocs.AddRangeAsync(monHocs);
                await _context.SaveChangesAsync();
            }
            #endregion

            #region PhanCong
            if (!await _context.PhanCongs.AnyAsync())
            {
                var phanCongs = new List<PhanCong>
                {
                    new() { Mamonhoc = 1, Manguoidung = "teacher001" }, // C/C++
                    new() { Mamonhoc = 2, Manguoidung = "teacher001" }, // Java
                    new() { Mamonhoc = 3, Manguoidung = "teacher002" }, // C#
                    new() { Mamonhoc = 4, Manguoidung = "teacher003" }, // Python
                    new() { Mamonhoc = 5, Manguoidung = "teacher003" }, // CSDL
                    new() { Mamonhoc = 6, Manguoidung = "teacher004" }, // Mạng
                    new() { Mamonhoc = 7, Manguoidung = "teacher004" }, // KTPM
                    new() { Mamonhoc = 8, Manguoidung = "teacher005" }, // Toán rời rạc
                    new() { Mamonhoc = 9, Manguoidung = "teacher002" }, // CTDL
                    new() { Mamonhoc = 10, Manguoidung = "teacher005" } // Hệ điều hành
                };
                await _context.PhanCongs.AddRangeAsync(phanCongs);
                await _context.SaveChangesAsync();
            }
            #endregion

            #region Chuong
            if (!await _context.Chuongs.AnyAsync())
            {
                var chuongs = new List<Chuong>
                {
                    // Lập trình C/C++ (Môn 1)
                    new() { Tenchuong = "Giới thiệu ngôn ngữ C/C++", Mamonhoc = 1, Nguoitao = "teacher001", Trangthai = true },
                    new() { Tenchuong = "Biến và kiểu dữ liệu", Mamonhoc = 1, Nguoitao = "teacher001", Trangthai = true },
                    new() { Tenchuong = "Cấu trúc điều khiển", Mamonhoc = 1, Nguoitao = "teacher001", Trangthai = true },
                    new() { Tenchuong = "Hàm và thủ tục", Mamonhoc = 1, Nguoitao = "teacher001", Trangthai = true },
                    new() { Tenchuong = "Mảng và con trỏ", Mamonhoc = 1, Nguoitao = "teacher001", Trangthai = true },
                    new() { Tenchuong = "Lập trình hướng đối tượng", Mamonhoc = 1, Nguoitao = "teacher001", Trangthai = true },

                    // Lập trình Java (Môn 2)
                    new() { Tenchuong = "Giới thiệu Java và JVM", Mamonhoc = 2, Nguoitao = "teacher001", Trangthai = true },
                    new() { Tenchuong = "Cú pháp cơ bản Java", Mamonhoc = 2, Nguoitao = "teacher001", Trangthai = true },
                    new() { Tenchuong = "Lập trình OOP trong Java", Mamonhoc = 2, Nguoitao = "teacher001", Trangthai = true },
                    new() { Tenchuong = "Exception Handling", Mamonhoc = 2, Nguoitao = "teacher001", Trangthai = true },
                    new() { Tenchuong = "Collections Framework", Mamonhoc = 2, Nguoitao = "teacher001", Trangthai = true },

                    // Lập trình C# (Môn 3)
                    new() { Tenchuong = "Giới thiệu .NET và C#", Mamonhoc = 3, Nguoitao = "teacher002", Trangthai = true },
                    new() { Tenchuong = "Cú pháp và kiểu dữ liệu C#", Mamonhoc = 3, Nguoitao = "teacher002", Trangthai = true },
                    new() { Tenchuong = "OOP trong C#", Mamonhoc = 3, Nguoitao = "teacher002", Trangthai = true },
                    new() { Tenchuong = "Windows Forms", Mamonhoc = 3, Nguoitao = "teacher002", Trangthai = true },
                    new() { Tenchuong = "ADO.NET và Database", Mamonhoc = 3, Nguoitao = "teacher002", Trangthai = true },

                    // Lập trình Python (Môn 4)
                    new() { Tenchuong = "Giới thiệu Python", Mamonhoc = 4, Nguoitao = "teacher003", Trangthai = true },
                    new() { Tenchuong = "Cú pháp cơ bản Python", Mamonhoc = 4, Nguoitao = "teacher003", Trangthai = true },
                    new() { Tenchuong = "Cấu trúc dữ liệu Python", Mamonhoc = 4, Nguoitao = "teacher003", Trangthai = true },
                    new() { Tenchuong = "Modules và Packages", Mamonhoc = 4, Nguoitao = "teacher003", Trangthai = true },
                    new() { Tenchuong = "File I/O và Exception", Mamonhoc = 4, Nguoitao = "teacher003", Trangthai = true },

                    // Cơ sở dữ liệu (Môn 5)
                    new() { Tenchuong = "Giới thiệu CSDL", Mamonhoc = 5, Nguoitao = "teacher003", Trangthai = true },
                    new() { Tenchuong = "Mô hình quan hệ", Mamonhoc = 5, Nguoitao = "teacher003", Trangthai = true },
                    new() { Tenchuong = "SQL cơ bản", Mamonhoc = 5, Nguoitao = "teacher003", Trangthai = true },
                    new() { Tenchuong = "Thiết kế CSDL", Mamonhoc = 5, Nguoitao = "teacher003", Trangthai = true },
                    new() { Tenchuong = "Stored Procedure và Trigger", Mamonhoc = 5, Nguoitao = "teacher003", Trangthai = true },

                    // Mạng máy tính (Môn 6)
                    new() { Tenchuong = "Giới thiệu mạng máy tính", Mamonhoc = 6, Nguoitao = "teacher004", Trangthai = true },
                    new() { Tenchuong = "Mô hình OSI và TCP/IP", Mamonhoc = 6, Nguoitao = "teacher004", Trangthai = true },
                    new() { Tenchuong = "Địa chỉ IP và Subnetting", Mamonhoc = 6, Nguoitao = "teacher004", Trangthai = true },
                    new() { Tenchuong = "Routing và Switching", Mamonhoc = 6, Nguoitao = "teacher004", Trangthai = true },
                    new() { Tenchuong = "Bảo mật mạng", Mamonhoc = 6, Nguoitao = "teacher004", Trangthai = true },

                    // Kỹ thuật phần mềm (Môn 7)
                    new() { Tenchuong = "Giới thiệu KTPM", Mamonhoc = 7, Nguoitao = "teacher004", Trangthai = true },
                    new() { Tenchuong = "Quy trình phát triển phần mềm", Mamonhoc = 7, Nguoitao = "teacher004", Trangthai = true },
                    new() { Tenchuong = "Phân tích yêu cầu", Mamonhoc = 7, Nguoitao = "teacher004", Trangthai = true },
                    new() { Tenchuong = "Thiết kế hệ thống", Mamonhoc = 7, Nguoitao = "teacher004", Trangthai = true },
                    new() { Tenchuong = "Testing và Maintenance", Mamonhoc = 7, Nguoitao = "teacher004", Trangthai = true },

                    // Toán rời rạc (Môn 8)
                    new() { Tenchuong = "Logic mệnh đề", Mamonhoc = 8, Nguoitao = "teacher005", Trangthai = true },
                    new() { Tenchuong = "Lý thuyết tập hợp", Mamonhoc = 8, Nguoitao = "teacher005", Trangthai = true },
                    new() { Tenchuong = "Quan hệ và hàm", Mamonhoc = 8, Nguoitao = "teacher005", Trangthai = true },
                    new() { Tenchuong = "Lý thuyết đồ thị", Mamonhoc = 8, Nguoitao = "teacher005", Trangthai = true },
                    new() { Tenchuong = "Tổ hợp và xác suất", Mamonhoc = 8, Nguoitao = "teacher005", Trangthai = true },

                    // Cấu trúc dữ liệu và giải thuật (Môn 9)
                    new() { Tenchuong = "Giới thiệu CTDL", Mamonhoc = 9, Nguoitao = "teacher002", Trangthai = true },
                    new() { Tenchuong = "Mảng và Danh sách liên kết", Mamonhoc = 9, Nguoitao = "teacher002", Trangthai = true },
                    new() { Tenchuong = "Stack và Queue", Mamonhoc = 9, Nguoitao = "teacher002", Trangthai = true },
                    new() { Tenchuong = "Cây và đồ thị", Mamonhoc = 9, Nguoitao = "teacher002", Trangthai = true },
                    new() { Tenchuong = "Thuật toán sắp xếp và tìm kiếm", Mamonhoc = 9, Nguoitao = "teacher002", Trangthai = true },

                    // Hệ điều hành (Môn 10)
                    new() { Tenchuong = "Giới thiệu hệ điều hành", Mamonhoc = 10, Nguoitao = "teacher005", Trangthai = true },
                    new() { Tenchuong = "Quản lý tiến trình", Mamonhoc = 10, Nguoitao = "teacher005", Trangthai = true },
                    new() { Tenchuong = "Quản lý bộ nhớ", Mamonhoc = 10, Nguoitao = "teacher005", Trangthai = true },
                    new() { Tenchuong = "Hệ thống file", Mamonhoc = 10, Nguoitao = "teacher005", Trangthai = true }
                };
                await _context.Chuongs.AddRangeAsync(chuongs);
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
                var cauHois = new List<CauHoi>
                {
                    // Lập trình C/C++ (Môn 1)
                    new() { Noidung = "Kiểu dữ liệu nào sau đây được sử dụng để lưu trữ số nguyên trong C++?", Dokho = 1, Mamonhoc = 1, Machuong = 2, Nguoitao = "teacher001", Loaicauhoi = "single_choice", Trangthai = true },
                    new() { Noidung = "Câu lệnh nào sau đây được sử dụng để khai báo một biến số nguyên có tên 'x' trong C++?", Dokho = 1, Mamonhoc = 1, Machuong = 2, Nguoitao = "teacher001", Loaicauhoi = "single_choice", Trangthai = true },
                    new() { Noidung = "Trong C++, toán tử nào được sử dụng để so sánh bằng?", Dokho = 1, Mamonhoc = 1, Machuong = 3, Nguoitao = "teacher001", Loaicauhoi = "single_choice", Trangthai = true },
                    new() { Noidung = "Vòng lặp for trong C++ có cú pháp như thế nào?", Dokho = 2, Mamonhoc = 1, Machuong = 3, Nguoitao = "teacher001", Loaicauhoi = "single_choice", Trangthai = true },
                    new() { Noidung = "Con trỏ trong C++ là gì?", Dokho = 3, Mamonhoc = 1, Machuong = 5, Nguoitao = "teacher001", Loaicauhoi = "single_choice", Trangthai = true },

                    // Lập trình Java (Môn 2)
                    new() { Noidung = "Java là ngôn ngữ lập trình hướng đối tượng.", Dokho = 1, Mamonhoc = 2, Machuong = 7, Nguoitao = "teacher001", Loaicauhoi = "single_choice", Trangthai = true },
                    new() { Noidung = "Từ khóa nào được sử dụng để khai báo một lớp trong Java?", Dokho = 1, Mamonhoc = 2, Machuong = 9, Nguoitao = "teacher001", Loaicauhoi = "single_choice", Trangthai = true },
                    new() { Noidung = "Phương thức main() trong Java có signature như thế nào?", Dokho = 2, Mamonhoc = 2, Machuong = 8, Nguoitao = "teacher001", Loaicauhoi = "single_choice", Trangthai = true },
                    new() { Noidung = "Exception handling trong Java sử dụng các từ khóa nào?", Dokho = 2, Mamonhoc = 2, Machuong = 10, Nguoitao = "teacher001", Loaicauhoi = "multiple_choice", Trangthai = true },
                    new() { Noidung = "ArrayList trong Java thuộc package nào?", Dokho = 2, Mamonhoc = 2, Machuong = 11, Nguoitao = "teacher001", Loaicauhoi = "single_choice", Trangthai = true }
                };
                await _context.CauHois.AddRangeAsync(cauHois);
                await _context.SaveChangesAsync();
            }
            #endregion

            #region CauTraLoi
            if (!await _context.CauTraLois.AnyAsync())
            {
                // Get the actual IDs of the created questions
                var cauHois = await _context.CauHois.OrderBy(c => c.Macauhoi).ToListAsync();
                if (cauHois.Count >= 10)
                {
                    var cauTraLois = new List<CauTraLoi>
                    {
                        // Câu hỏi 1: Kiểu dữ liệu số nguyên trong C++
                        new() { Macauhoi = cauHois[0].Macauhoi, Noidungtl = "int", Dapan = true },
                        new() { Macauhoi = cauHois[0].Macauhoi, Noidungtl = "float", Dapan = false },
                        new() { Macauhoi = cauHois[0].Macauhoi, Noidungtl = "char", Dapan = false },
                        new() { Macauhoi = cauHois[0].Macauhoi, Noidungtl = "string", Dapan = false },

                        // Câu hỏi 2: Khai báo biến trong C++
                        new() { Macauhoi = cauHois[1].Macauhoi, Noidungtl = "int x;", Dapan = true },
                        new() { Macauhoi = cauHois[1].Macauhoi, Noidungtl = "integer x;", Dapan = false },
                        new() { Macauhoi = cauHois[1].Macauhoi, Noidungtl = "var x;", Dapan = false },
                        new() { Macauhoi = cauHois[1].Macauhoi, Noidungtl = "x int;", Dapan = false },

                        // Câu hỏi 3: Toán tử so sánh bằng
                        new() { Macauhoi = cauHois[2].Macauhoi, Noidungtl = "==", Dapan = true },
                        new() { Macauhoi = cauHois[2].Macauhoi, Noidungtl = "=", Dapan = false },
                        new() { Macauhoi = cauHois[2].Macauhoi, Noidungtl = "!=", Dapan = false },
                        new() { Macauhoi = cauHois[2].Macauhoi, Noidungtl = "===", Dapan = false },

                        // Câu hỏi 4: Vòng lặp for
                        new() { Macauhoi = cauHois[3].Macauhoi, Noidungtl = "for(int i=0; i<n; i++)", Dapan = true },
                        new() { Macauhoi = cauHois[3].Macauhoi, Noidungtl = "for(i=0; i<n; i++)", Dapan = false },
                        new() { Macauhoi = cauHois[3].Macauhoi, Noidungtl = "for i in range(n)", Dapan = false },
                        new() { Macauhoi = cauHois[3].Macauhoi, Noidungtl = "for(i; i<n; i++)", Dapan = false },

                        // Câu hỏi 5: Con trỏ trong C++
                        new() { Macauhoi = cauHois[4].Macauhoi, Noidungtl = "Biến lưu trữ địa chỉ của biến khác", Dapan = true },
                        new() { Macauhoi = cauHois[4].Macauhoi, Noidungtl = "Biến lưu trữ giá trị số nguyên", Dapan = false },
                        new() { Macauhoi = cauHois[4].Macauhoi, Noidungtl = "Hàm đặc biệt trong C++", Dapan = false },
                        new() { Macauhoi = cauHois[4].Macauhoi, Noidungtl = "Kiểu dữ liệu chuỗi", Dapan = false },

                        // Câu hỏi 6: Java là ngôn ngữ OOP
                        new() { Macauhoi = cauHois[5].Macauhoi, Noidungtl = "Đúng", Dapan = true },
                        new() { Macauhoi = cauHois[5].Macauhoi, Noidungtl = "Sai", Dapan = false },

                        // Câu hỏi 7: Khai báo lớp trong Java
                        new() { Macauhoi = cauHois[6].Macauhoi, Noidungtl = "class", Dapan = true },
                        new() { Macauhoi = cauHois[6].Macauhoi, Noidungtl = "Class", Dapan = false },
                        new() { Macauhoi = cauHois[6].Macauhoi, Noidungtl = "public", Dapan = false },
                        new() { Macauhoi = cauHois[6].Macauhoi, Noidungtl = "object", Dapan = false },

                        // Câu hỏi 8: Phương thức main()
                        new() { Macauhoi = cauHois[7].Macauhoi, Noidungtl = "public static void main(String[] args)", Dapan = true },
                        new() { Macauhoi = cauHois[7].Macauhoi, Noidungtl = "public void main(String[] args)", Dapan = false },
                        new() { Macauhoi = cauHois[7].Macauhoi, Noidungtl = "static void main(String[] args)", Dapan = false },
                        new() { Macauhoi = cauHois[7].Macauhoi, Noidungtl = "public static main(String[] args)", Dapan = false },

                        // Câu hỏi 9: Exception handling (multiple choice)
                        new() { Macauhoi = cauHois[8].Macauhoi, Noidungtl = "try", Dapan = true },
                        new() { Macauhoi = cauHois[8].Macauhoi, Noidungtl = "catch", Dapan = true },
                        new() { Macauhoi = cauHois[8].Macauhoi, Noidungtl = "finally", Dapan = true },
                        new() { Macauhoi = cauHois[8].Macauhoi, Noidungtl = "throw", Dapan = true },
                        new() { Macauhoi = cauHois[8].Macauhoi, Noidungtl = "except", Dapan = false },

                        // Câu hỏi 10: ArrayList package
                        new() { Macauhoi = cauHois[9].Macauhoi, Noidungtl = "java.util", Dapan = true },
                        new() { Macauhoi = cauHois[9].Macauhoi, Noidungtl = "java.lang", Dapan = false },
                        new() { Macauhoi = cauHois[9].Macauhoi, Noidungtl = "java.io", Dapan = false },
                        new() { Macauhoi = cauHois[9].Macauhoi, Noidungtl = "java.awt", Dapan = false }
                    };
                    await _context.CauTraLois.AddRangeAsync(cauTraLois);
                    await _context.SaveChangesAsync();
                }
            }
            #endregion

            #region DeThi
            if (!await _context.DeThis.AnyAsync())
            {
                var deThis = new List<DeThi>
                {
                    new() { Monthi = 1, Nguoitao = "teacher001", Tende = "Kiểm tra giữa kỳ - Lập trình C++", Thoigiantao = DateTime.Now.AddDays(-10), Thoigianthi = 60, Thoigiantbatdau = DateTime.Now.AddDays(5), Thoigianketthuc = DateTime.Now.AddDays(5).AddHours(1), Hienthibailam = true, Xemdiemthi = true, Xemdapan = false, Troncauhoi = true, Loaide = 1, Socaude = 2, Socautb = 3, Socaukho = 1, Trangthai = true },
                    new() { Monthi = 2, Nguoitao = "teacher001", Tende = "Bài kiểm tra Java cơ bản", Thoigiantao = DateTime.Now.AddDays(-8), Thoigianthi = 45, Thoigiantbatdau = DateTime.Now.AddDays(7), Thoigianketthuc = DateTime.Now.AddDays(7).AddMinutes(45), Hienthibailam = true, Xemdiemthi = true, Xemdapan = true, Troncauhoi = false, Loaide = 1, Socaude = 3, Socautb = 2, Socaukho = 1, Trangthai = true },
                    new() { Monthi = 3, Nguoitao = "teacher002", Tende = "Đề thi cuối kỳ - C# Programming", Thoigiantao = DateTime.Now.AddDays(-5), Thoigianthi = 90, Thoigiantbatdau = DateTime.Now.AddDays(15), Thoigianketthuc = DateTime.Now.AddDays(15).AddMinutes(90), Hienthibailam = false, Xemdiemthi = false, Xemdapan = false, Troncauhoi = true, Loaide = 2, Socaude = 3, Socautb = 4, Socaukho = 3, Trangthai = true },
                    new() { Monthi = 4, Nguoitao = "teacher003", Tende = "Quiz Python - Chương 1", Thoigiantao = DateTime.Now.AddDays(-3), Thoigianthi = 30, Thoigiantbatdau = DateTime.Now.AddDays(2), Thoigianketthuc = DateTime.Now.AddDays(2).AddMinutes(30), Hienthibailam = true, Xemdiemthi = true, Xemdapan = true, Troncauhoi = false, Loaide = 1, Socaude = 5, Socautb = 0, Socaukho = 0, Trangthai = true }
                };
                await _context.DeThis.AddRangeAsync(deThis);
                await _context.SaveChangesAsync();
            }
            #endregion

            // Tạm thời bỏ qua ChiTietDeThi vì cần ID tự động từ DeThi và CauHoi

            #region ThongBao
            if (!await _context.ThongBaos.AnyAsync())
            {
                var thongBaos = new List<ThongBao>
                {
                    new() { Noidung = "Thông báo: Lịch thi giữa kỳ môn Lập trình C++ sẽ diễn ra vào tuần tới. Sinh viên chuẩn bị ôn tập kỹ.", Thoigiantao = DateTime.Now.AddDays(-2), Nguoitao = "teacher001" },
                    new() { Noidung = "Bài tập lớn môn Java đã được cập nhật trên hệ thống. Hạn nộp: cuối tuần này.", Thoigiantao = DateTime.Now.AddDays(-1), Nguoitao = "teacher001" },
                    new() { Noidung = "Lịch học bù môn C# Programming: Thứ 7 tuần này từ 8h-11h tại phòng Lab 2.", Thoigiantao = DateTime.Now.AddHours(-5), Nguoitao = "teacher002" },
                    new() { Noidung = "Quiz Python chương 1 sẽ mở vào ngày mai. Thời gian làm bài: 30 phút.", Thoigiantao = DateTime.Now.AddHours(-2), Nguoitao = "teacher003" },
                    new() { Noidung = "Thông báo nghỉ học: Lớp Database Systems nghỉ học vào thứ 5 tuần này do giảng viên có công tác.", Thoigiantao = DateTime.Now.AddHours(-1), Nguoitao = "teacher003" }
                };
                await _context.ThongBaos.AddRangeAsync(thongBaos);
                await _context.SaveChangesAsync();
            }
            #endregion

            // Tạm thời bỏ qua KetQua và ChiTietKetQua vì cần ID tự động

            await _context.SaveChangesAsync();
        }
    }
}