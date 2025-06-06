using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using CKCQUIZZ.Server.Models;
using Microsoft.AspNetCore.Identity;

namespace CKCQUIZZ.Server.Data
{
    public class SeedData
    {
        private readonly CkcquizzContext _context;
        private readonly UserManager<NguoiDung> _userManger;
        private readonly RoleManager<IdentityRole> _roleManager;
        private readonly string AdminRoleName = "Admin";
        private readonly string StudentRoleName = "Student";
        private readonly string TeacherRoleName = "Teacher";

        public SeedData(CkcquizzContext context, UserManager<NguoiDung> userManager, RoleManager<IdentityRole> roleManager)
        {
            _context = context;
            _userManger = userManager;
            _roleManager = roleManager;
        }

        public async Task Seed()
        {
            #region Quyen

            if (!_roleManager.Roles.Any())
            {
                await _roleManager.CreateAsync(new IdentityRole
                {
                    Id = AdminRoleName,
                    Name = AdminRoleName,
                    NormalizedName = AdminRoleName.ToUpper(),
                });
                await _roleManager.CreateAsync(new IdentityRole
                {
                    Id = TeacherRoleName,
                    Name = TeacherRoleName,
                    NormalizedName = TeacherRoleName.ToUpper(),
                });
                await _roleManager.CreateAsync(new IdentityRole
                {
                    Id = StudentRoleName,
                    Name = StudentRoleName,
                    NormalizedName = StudentRoleName.ToUpper(),
                });
            }
            #endregion Quyen

            #region NguoiDung

            if (!_userManger.Users.Any())
            {

                var result = await _userManger.CreateAsync(new NguoiDung
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
                    var user = await _userManger.FindByNameAsync("Admin");
                    await _userManger.AddToRoleAsync(user ?? default!, AdminRoleName);
                }
                var teacherResult = await _userManger.CreateAsync(new NguoiDung
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
                    var teacher = await _userManger.FindByNameAsync("teacher1");
                    await _userManger.AddToRoleAsync(teacher ?? default!, TeacherRoleName);
                }

                var student1Result = await _userManger.CreateAsync(new NguoiDung
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
                    var student1 = await _userManger.FindByNameAsync("student1");
                    await _userManger.AddToRoleAsync(student1 ?? default!, StudentRoleName);
                }
                var teacherResult2 = await _userManger.CreateAsync(new NguoiDung
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
                    var teacher = await _userManger.FindByNameAsync("teacher2");
                    await _userManger.AddToRoleAsync(teacher ?? default!, TeacherRoleName);
                }

                var student2Result = await _userManger.CreateAsync(new NguoiDung
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
                    var student2 = await _userManger.FindByNameAsync("student2");
                    await _userManger.AddToRoleAsync(student2 ?? default!, StudentRoleName);
                }
                var student3Result = await _userManger.CreateAsync(new NguoiDung
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
                    var student3 = await _userManger.FindByNameAsync("student3");
                    await _userManger.AddToRoleAsync(student3 ?? default!, StudentRoleName);
                }
                var student4Result = await _userManger.CreateAsync(new NguoiDung
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
                    var student4 = await _userManger.FindByNameAsync("student4");
                    await _userManger.AddToRoleAsync(student4 ?? default!, StudentRoleName);
                }
                var student5Result = await _userManger.CreateAsync(new NguoiDung
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
                    var student5 = await _userManger.FindByNameAsync("student5");
                    await _userManger.AddToRoleAsync(student5 ?? default!, StudentRoleName);
                }
                var student6Result = await _userManger.CreateAsync(new NguoiDung
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
                    var student6 = await _userManger.FindByNameAsync("student6");
                    await _userManger.AddToRoleAsync(student6 ?? default!, StudentRoleName);
                }
                var student7Result = await _userManger.CreateAsync(new NguoiDung
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
                    var student7 = await _userManger.FindByNameAsync("student7");
                    await _userManger.AddToRoleAsync(student7 ?? default!, StudentRoleName);
                }
                var student8Result = await _userManger.CreateAsync(new NguoiDung
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
                    var student8 = await _userManger.FindByNameAsync("student8");
                    await _userManger.AddToRoleAsync(student8 ?? default!, StudentRoleName);
                }
            }

            #endregion NguoiDung

            await _context.SaveChangesAsync();
        }
    }
}