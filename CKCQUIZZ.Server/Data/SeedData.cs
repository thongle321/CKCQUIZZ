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
                    Trangthai = true,
                }, "Hocsinh123@");

                if (student1Result.Succeeded)
                {
                    var student1 = await _userManger.FindByNameAsync("student1");
                    await _userManger.AddToRoleAsync(student1 ?? default!, StudentRoleName);
                }
            }

            #endregion NguoiDung

            await _context.SaveChangesAsync();
        }
    }
}