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

            await _context.SaveChangesAsync();
        }
    }
}