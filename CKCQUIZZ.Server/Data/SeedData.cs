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
                    Id = "0306221011",
                    UserName = "teacher1",
                    Hoten = "Thầy Nguyễn Văn A",
                    Email = "0306221011@caothang.edu.vn",
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
                    Id = "0306221377",
                    UserName = "LNHT",
                    Hoten = "Lê Nguyễn Hoàng Thông",
                    Email = "0306221377@caothang.edu.vn",
                    Gioitinh = false,
                    Ngaysinh = new DateTime(2006, 3, 14),
                    Avatar = null,
                    Ngaythamgia = DateTime.Today,
                    PhoneNumber = "2401495012",
                    Trangthai = true,
                }, "Hocsinh123@");

                if (student1Result.Succeeded)
                {
                    var student1 = await _userManager.FindByNameAsync("LNHT");
                    await _userManager.AddToRoleAsync(student1 ?? default!, StudentRoleName);
                }
                var teacherResult2 = await _userManager.CreateAsync(new NguoiDung
                {
                    Id = "0306221012",
                    UserName = "teacher2",
                    Hoten = "Thầy Nguyễn Văn B",
                    Email = "0306221012@caothang.edu.vn",
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
                    Id = "0306221020",
                    UserName = "HMH",
                    Hoten = "Hoàng Minh Hiếu",
                    Email = "0306221020@caothang.edu.vn",
                    Gioitinh = false,
                    Ngaysinh = new DateTime(2006, 3, 14),
                    Avatar = null,
                    Ngaythamgia = DateTime.Today,
                    PhoneNumber = "2401495013",
                    Trangthai = true,
                }, "Hocsinh123@");

                if (student2Result.Succeeded)
                {
                    var student2 = await _userManager.FindByNameAsync("HMH");
                    await _userManager.AddToRoleAsync(student2 ?? default!, StudentRoleName);
                }
                var student3Result = await _userManager.CreateAsync(new NguoiDung
                {
                    Id = "0306221022",
                    UserName = "DXH",
                    Hoten = "Đinh Xuân Hoàng",
                    Email = "0306221022@caothang.edu.vn",
                    Gioitinh = false,
                    Ngaysinh = new DateTime(2006, 3, 14),
                    Avatar = null,
                    Ngaythamgia = DateTime.Today,
                    PhoneNumber = "2401495015",
                    Trangthai = true,
                }, "Hocsinh123@");

                if (student3Result.Succeeded)
                {
                    var student3 = await _userManager.FindByNameAsync("DXH");
                    await _userManager.AddToRoleAsync(student3 ?? default!, StudentRoleName);
                }
                var student4Result = await _userManager.CreateAsync(new NguoiDung
                {
                    Id = "0306221024",
                    UserName = "student4",
                    Hoten = "Trần Văn E",
                    Email = "0306221024@caothang.edu.vn",
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
                    Id = "0306221025",
                    UserName = "student5",
                    Hoten = "Trần Văn X",
                    Email = "0306221025@caothang.edu.vn",
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
                    Id = "0306221026",
                    UserName = "student6",
                    Hoten = "Trần Văn M",
                    Email = "0306221026@caothang.edu.vn",
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
                    Id = "0306221027",
                    UserName = "student7",
                    Hoten = "Trần Văn P",
                    Email = "0306221027@caothang.edu.vn",
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
                    Id = "0306221028",
                    UserName = "student8",
                    Hoten = "Trần Văn E",
                    Email = "0306221028@caothang.edu.vn",
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



                var teacherFullAccessFunctions = new[] {  "hocphan", "monhoc", "thongbao", "chuong", "cauhoi", "dethi", "nguoidung"};
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
                #endregion

                #region Seed Chuong Data
                var chuongs = new List<Chuong>
                {
                    new() { Tenchuong = "Khái niệm cơ bản C#", Mamonhoc = 734846, Nguoitao = "teacher001", Trangthai = true },
                    new() { Tenchuong = "Lập trình hướng đối tượng", Mamonhoc = 734846, Nguoitao = "teacher001", Trangthai = true },
                    new() { Tenchuong = "Các cấu trúc dữ liệu cơ bản", Mamonhoc = 227095, Nguoitao = "teacher002", Trangthai = true },
                    new() { Tenchuong = "Thuật toán tìm kiếm và sắp xếp", Mamonhoc = 227095, Nguoitao = "teacher002", Trangthai = true },
                    new() { Tenchuong = "Ngôn ngữ SQL và Tối ưu hóa", Mamonhoc = 460154, Nguoitao = "teacher001", Trangthai = true },
                    new() { Tenchuong = "Mô hình OSI và TCP/IP", Mamonhoc = 645403, Nguoitao = "teacher002", Trangthai = true },
                    new() { Tenchuong = "Quản lý tiến trình và bộ nhớ", Mamonhoc = 732237, Nguoitao = "teacher002", Trangthai = true },
                    new() { Tenchuong = "Giải tích và Đại số", Mamonhoc = 570488, Nguoitao = "teacher001", Trangthai = true },
                    new() { Tenchuong = "Cơ học", Mamonhoc = 673119, Nguoitao = "teacher001", Trangthai = true }
                };
                await _context.Chuongs.AddRangeAsync(chuongs);
                await _context.SaveChangesAsync();
                #endregion
            }
            if (!await _context.CauHois.AnyAsync())
            {
                var cauHoisAndTraLois = new List<CauHoi>
            {
        #region Single Choice Questions with Answers
        new()
        {
            Noidung = "Trong C#, phương thức nào được gọi tự động khi một đối tượng được tạo?", Dokho = 1, Mamonhoc = 734846, Machuong = 1, Nguoitao = "teacher001", Loaicauhoi = "single_choice", Trangthai = true,
            CauTraLois =
            {
                new() { Noidungtl = "Constructor", Dapan = true },
                new() { Noidungtl = "Destructor", Dapan = false },
                new() { Noidungtl = "Main", Dapan = false },
                new() { Noidungtl = "Static method", Dapan = false }
            }
        },
        new()
        {
            Noidung = "Đâu là kiểu dữ liệu tham trị (value type) trong C#?", Dokho = 1, Mamonhoc = 734846, Machuong = 2, Nguoitao = "teacher001", Loaicauhoi = "single_choice", Trangthai = true,
            CauTraLois =
            {
                new() { Noidungtl = "int", Dapan = true },
                new() { Noidungtl = "string", Dapan = false },
                new() { Noidungtl = "object", Dapan = false },
                new() { Noidungtl = "Array", Dapan = false }
            }
        },
        new()
        {
            Noidung = "Để sắp xếp một danh sách các phần tử, cấu trúc dữ liệu nào thường được ưu tiên về hiệu năng tìm kiếm?", Dokho = 2, Mamonhoc = 227095, Machuong = 3, Nguoitao = "teacher002", Loaicauhoi = "single_choice", Trangthai = true,
            CauTraLois =
            {
                new() { Noidungtl = "Cây tìm kiếm nhị phân (Binary Search Tree)", Dapan = true },
                new() { Noidungtl = "Danh sách liên kết (Linked List)", Dapan = false },
                new() { Noidungtl = "Hàng đợi (Queue)", Dapan = false },
                new() { Noidungtl = "Ngăn xếp (Stack)", Dapan = false }
            }
        },
        new()
        {
            Noidung = "Độ phức tạp của thuật toán tìm kiếm nhị phân (Binary Search) là gì?", Dokho = 2, Mamonhoc = 227095, Machuong = 4, Nguoitao = "teacher002", Loaicauhoi = "single_choice", Trangthai = true,
            CauTraLois =
            {
                new() { Noidungtl = "O(log n)", Dapan = true },
                new() { Noidungtl = "O(n)", Dapan = false },
                new() { Noidungtl = "O(n log n)", Dapan = false },
                new() { Noidungtl = "O(n^2)", Dapan = false }
            }
        },
        new()
        {
            Noidung = "Trong SQL, mệnh đề nào được sử dụng để lọc kết quả dựa trên một điều kiện?", Dokho = 1, Mamonhoc = 460154, Machuong = 5, Nguoitao = "teacher001", Loaicauhoi = "single_choice", Trangthai = true,
            CauTraLois =
            {
                new() { Noidungtl = "WHERE", Dapan = true },
                new() { Noidungtl = "FROM", Dapan = false },
                new() { Noidungtl = "GROUP BY", Dapan = false },
                new() { Noidungtl = "HAVING", Dapan = false }
            }
        },
        new()
        {
            Noidung = "Loại JOIN nào trong SQL sẽ trả về tất cả các hàng từ bảng bên trái và các hàng phù hợp từ bảng bên phải?", Dokho = 2, Mamonhoc = 460154, Machuong = 5, Nguoitao = "teacher001", Loaicauhoi = "single_choice", Trangthai = true,
            CauTraLois =
            {
                new() { Noidungtl = "LEFT JOIN", Dapan = true },
                new() { Noidungtl = "INNER JOIN", Dapan = false },
                new() { Noidungtl = "RIGHT JOIN", Dapan = false },
                new() { Noidungtl = "FULL OUTER JOIN", Dapan = false }
            }
        },
        new()
        {
            Noidung = "Địa chỉ IP \"127.0.0.1\" thường được gọi là gì?", Dokho = 1, Mamonhoc = 645403, Machuong = 6, Nguoitao = "teacher001", Loaicauhoi = "single_choice", Trangthai = true,
            CauTraLois =
            {
                new() { Noidungtl = "Loopback Address (Địa chỉ loopback)", Dapan = true },
                new() { Noidungtl = "Broadcast Address (Địa chỉ broadcast)", Dapan = false },
                new() { Noidungtl = "Gateway Address (Địa chỉ cổng)", Dapan = false },
                new() { Noidungtl = "Public Address (Địa chỉ công cộng)", Dapan = false }
            }
        },
        new()
        {
            Noidung = "Tầng nào trong mô hình OSI chịu trách nhiệm định tuyến các gói tin?", Dokho = 3, Mamonhoc = 645403, Machuong = 6, Nguoitao = "teacher002", Loaicauhoi = "single_choice", Trangthai = true,
            CauTraLois =
            {
                new() { Noidungtl = "Tầng Mạng (Network Layer)", Dapan = true },
                new() { Noidungtl = "Tầng Giao vận (Transport Layer)", Dapan = false },
                new() { Noidungtl = "Tầng Liên kết dữ liệu (Data Link Layer)", Dapan = false },
                new() { Noidungtl = "Tầng Vật lý (Physical Layer)", Dapan = false }
            }
        },
        new()
        {
            Noidung = "Tiến trình (process) và luồng (thread) khác nhau ở điểm nào cơ bản nhất?", Dokho = 2, Mamonhoc = 732237, Machuong = 7, Nguoitao = "teacher002", Loaicauhoi = "single_choice", Trangthai = true,
            CauTraLois =
            {
                new() { Noidungtl = "Không gian bộ nhớ (Memory Space)", Dapan = true },
                new() { Noidungtl = "Mã thực thi (Execution Code)", Dapan = false },
                new() { Noidungtl = "Các file đang mở", Dapan = false },
                new() { Noidungtl = "Quyền truy cập tài nguyên", Dapan = false }
            }
        },
        new()
        {
            Noidung = "Thuật toán lập lịch CPU nào có thể gây ra \"nạn đói\" (starvation)?", Dokho = 3, Mamonhoc = 732237, Machuong = 7, Nguoitao = "teacher002", Loaicauhoi = "single_choice", Trangthai = true,
            CauTraLois =
            {
                new() { Noidungtl = "Priority Scheduling (Lập lịch ưu tiên)", Dapan = true },
                new() { Noidungtl = "First-Come, First-Served (FCFS)", Dapan = false },
                new() { Noidungtl = "Round Robin (RR)", Dapan = false },
                new() { Noidungtl = "Shortest-Job-First (SJF) - Preemptive", Dapan = false }
            }
        },
        new()
        {
            Noidung = "Hệ số góc của đường thẳng y = 3x - 5 là bao nhiêu?", Dokho = 1, Mamonhoc = 570488, Machuong = 8, Nguoitao = "teacher001", Loaicauhoi = "single_choice", Trangthai = true,
            CauTraLois =
            {
                new() { Noidungtl = "3", Dapan = true },
                new() { Noidungtl = "-5", Dapan = false },
                new() { Noidungtl = "5", Dapan = false },
                new() { Noidungtl = "3x", Dapan = false }
            }
        },
        new()
        {
            Noidung = "Đạo hàm của hàm số f(x) = x^3 là gì?", Dokho = 1, Mamonhoc = 570488, Machuong = 8, Nguoitao = "teacher001", Loaicauhoi = "single_choice", Trangthai = true,
            CauTraLois =
            {
                new() { Noidungtl = "3x^2", Dapan = true },
                new() { Noidungtl = "x^2", Dapan = false },
                new() { Noidungtl = "3x", Dapan = false },
                new() { Noidungtl = "(x^4)/4", Dapan = false }
            }
        },
        new()
        {
            Noidung = "Đơn vị của gia tốc trong hệ SI là gì?", Dokho = 1, Mamonhoc = 673119, Machuong = 9, Nguoitao = "teacher001", Loaicauhoi = "single_choice", Trangthai = true,
            CauTraLois =
            {
                new() { Noidungtl = "m/s^2", Dapan = true },
                new() { Noidungtl = "m/s", Dapan = false },
                new() { Noidungtl = "N (Newton)", Dapan = false },
                new() { Noidungtl = "kg", Dapan = false }
            }
        },
        new()
        {
            Noidung = "Lực ma sát nghỉ cực đại phụ thuộc vào yếu tố nào?", Dokho = 2, Mamonhoc = 673119, Machuong = 9, Nguoitao = "teacher002", Loaicauhoi = "single_choice", Trangthai = true,
            CauTraLois =
            {
                new() { Noidungtl = "Áp lực và bản chất của hai mặt tiếp xúc", Dapan = true },
                new() { Noidungtl = "Diện tích mặt tiếp xúc", Dapan = false },
                new() { Noidungtl = "Vận tốc của vật", Dapan = false },
                new() { Noidungtl = "Khối lượng của vật", Dapan = false }
            }
        },
        new()
        {
            Noidung = "Từ khóa \"virtual\" trong C# được sử dụng để làm gì?", Dokho = 2, Mamonhoc = 734846, Machuong = 2, Nguoitao = "teacher001", Loaicauhoi = "single_choice", Trangthai = true,
            CauTraLois =
            {
                new() { Noidungtl = "Cho phép một phương thức ở lớp cơ sở có thể được ghi đè (override) ở lớp dẫn xuất", Dapan = true },
                new() { Noidungtl = "Khai báo một phương thức trừu tượng không có thân hàm", Dapan = false },
                new() { Noidungtl = "Ngăn không cho một lớp được kế thừa", Dapan = false },
                new() { Noidungtl = "Tạo một bản sao của đối tượng", Dapan = false }
            }
        },
        new()
        {
            Noidung = "Trong CSDL, khóa chính (Primary Key) có đặc điểm gì?", Dokho = 1, Mamonhoc = 460154, Machuong = 5, Nguoitao = "teacher001", Loaicauhoi = "single_choice", Trangthai = true,
            CauTraLois =
            {
                new() { Noidungtl = "Phải là duy nhất và không được chứa giá trị NULL", Dapan = true },
                new() { Noidungtl = "Có thể chứa giá trị NULL", Dapan = false },
                new() { Noidungtl = "Có thể có nhiều giá trị trùng lặp", Dapan = false },
                new() { Noidungtl = "Chỉ được dùng để liên kết với bảng khác", Dapan = false }
            }
        },
        new()
        {
            Noidung = "Cấu trúc \"Stack\" hoạt động theo nguyên tắc nào?", Dokho = 1, Mamonhoc = 227095, Machuong = 3, Nguoitao = "teacher002", Loaicauhoi = "single_choice", Trangthai = true,
            CauTraLois =
            {
                new() { Noidungtl = "LIFO (Last-In, First-Out)", Dapan = true },
                new() { Noidungtl = "FIFO (First-In, First-Out)", Dapan = false },
                new() { Noidungtl = "Random Access", Dapan = false },
                new() { Noidungtl = "Priority Queue", Dapan = false }
            }
        },
        new()
        {
            Noidung = "Giao thức HTTP hoạt động ở cổng mặc định nào?", Dokho = 1, Mamonhoc = 645403, Machuong = 6, Nguoitao = "teacher001", Loaicauhoi = "single_choice", Trangthai = true,
            CauTraLois =
            {
                new() { Noidungtl = "80", Dapan = true },
                new() { Noidungtl = "443", Dapan = false },
                new() { Noidungtl = "21", Dapan = false },
                new() { Noidungtl = "25", Dapan = false }
            }
        },
        new()
        {
            Noidung = "\"Deadlock\" trong hệ điều hành là tình trạng gì?", Dokho = 3, Mamonhoc = 732237, Machuong = 7, Nguoitao = "teacher002", Loaicauhoi = "single_choice", Trangthai = true,
            CauTraLois =
            {
                new() { Noidungtl = "Các tiến trình chờ đợi tài nguyên của nhau và không tiến trình nào có thể tiếp tục", Dapan = true },
                new() { Noidungtl = "Một tiến trình có độ ưu tiên thấp không bao giờ được thực thi", Dapan = false },
                new() { Noidungtl = "Hệ điều hành không thể phân bổ bộ nhớ cho tiến trình mới", Dapan = false },
                new() { Noidungtl = "Hai tiến trình cùng truy cập vào một vùng dữ liệu chia sẻ", Dapan = false }
            }
        },
        new()
        {
            Noidung = "Tích phân của hàm số f(x) = 2x là gì?", Dokho = 2, Mamonhoc = 570488, Machuong = 8, Nguoitao = "teacher001", Loaicauhoi = "single_choice", Trangthai = true,
            CauTraLois =
            {
                new() { Noidungtl = "x^2 + C", Dapan = true },
                new() { Noidungtl = "2", Dapan = false },
                new() { Noidungtl = "2x^2 + C", Dapan = false },
                new() { Noidungtl = "x^2", Dapan = false }
            }
        },
        #endregion

        #region Multiple Choice Questions with Answers
        new()
        {
            Noidung = "Những từ khóa nào sau đây là access modifier trong C#?", Dokho = 2, Mamonhoc = 734846, Machuong = 1, Nguoitao = "teacher001", Loaicauhoi = "multiple_choice", Trangthai = true,
            CauTraLois =
            {
                new() { Noidungtl = "public", Dapan = true },
                new() { Noidungtl = "private", Dapan = true },
                new() { Noidungtl = "internal", Dapan = true },
                new() { Noidungtl = "static", Dapan = false }
            }
        },
        new()
        {
            Noidung = "Các nguyên tắc của lập trình hướng đối tượng (OOP) bao gồm những gì?", Dokho = 2, Mamonhoc = 734846, Machuong = 2, Nguoitao = "teacher001", Loaicauhoi = "multiple_choice", Trangthai = true,
            CauTraLois =
            {
                new() { Noidungtl = "Tính đóng gói (Encapsulation)", Dapan = true },
                new() { Noidungtl = "Tính kế thừa (Inheritance)", Dapan = true },
                new() { Noidungtl = "Tính đa hình (Polymorphism)", Dapan = true },
                new() { Noidungtl = "Tính cấu trúc (Structured)", Dapan = false }
            }
        },
        new()
        {
            Noidung = "Những thuật toán sắp xếp nào có độ phức tạp trung bình là O(n log n)?", Dokho = 3, Mamonhoc = 227095, Machuong = 4, Nguoitao = "teacher002", Loaicauhoi = "multiple_choice", Trangthai = true,
            CauTraLois =
            {
                new() { Noidungtl = "Quick Sort", Dapan = true },
                new() { Noidungtl = "Merge Sort", Dapan = true },
                new() { Noidungtl = "Heap Sort", Dapan = true },
                new() { Noidungtl = "Bubble Sort", Dapan = false }
            }
        },
        new()
        {
            Noidung = "Cấu trúc dữ liệu cây (Tree) có những loại nào phổ biến?", Dokho = 2, Mamonhoc = 227095, Machuong = 3, Nguoitao = "teacher002", Loaicauhoi = "multiple_choice", Trangthai = true,
            CauTraLois =
            {
                new() { Noidungtl = "Cây nhị phân (Binary Tree)", Dapan = true },
                new() { Noidungtl = "Cây đỏ-đen (Red-Black Tree)", Dapan = true },
                new() { Noidungtl = "Cây B (B-Tree)", Dapan = true },
                new() { Noidungtl = "Cây hàng đợi (Queue Tree)", Dapan = false }
            }
        },
        new()
        {
            Noidung = "Các loại ràng buộc (constraint) nào có trong SQL?", Dokho = 2, Mamonhoc = 460154, Machuong = 5, Nguoitao = "teacher001", Loaicauhoi = "multiple_choice", Trangthai = true,
            CauTraLois =
            {
                new() { Noidungtl = "PRIMARY KEY", Dapan = true },
                new() { Noidungtl = "FOREIGN KEY", Dapan = true },
                new() { Noidungtl = "UNIQUE", Dapan = true },
                new() { Noidungtl = "INDEX", Dapan = false }
            }
        },
        new()
        {
            Noidung = "Những câu lệnh nào thuộc nhóm DML (Data Manipulation Language) trong SQL?", Dokho = 1, Mamonhoc = 460154, Machuong = 5, Nguoitao = "teacher001", Loaicauhoi = "multiple_choice", Trangthai = true,
            CauTraLois =
            {
                new() { Noidungtl = "INSERT", Dapan = true },
                new() { Noidungtl = "UPDATE", Dapan = true },
                new() { Noidungtl = "DELETE", Dapan = true },
                new() { Noidungtl = "CREATE", Dapan = false }
            }
        },
                new()
        {
            Noidung = "Các thiết bị mạng nào sau đây hoạt động ở tầng 2 (Data Link) của mô hình OSI?", Dokho = 2, Mamonhoc = 645403, Machuong = 6, Nguoitao = "teacher002", Loaicauhoi = "multiple_choice", Trangthai = true,
            CauTraLois =
            {
                new() { Noidungtl = "Switch", Dapan = true },
                new() { Noidungtl = "Bridge", Dapan = true },
                new() { Noidungtl = "Router", Dapan = false },
                new() { Noidungtl = "Hub", Dapan = false }
            }
        },
        new()
        {
            Noidung = "Những giao thức nào thuộc bộ giao thức TCP/IP?", Dokho = 1, Mamonhoc = 645403, Machuong = 6, Nguoitao = "teacher001", Loaicauhoi = "multiple_choice", Trangthai = true,
            CauTraLois =
            {
                new() { Noidungtl = "HTTP", Dapan = true },
                new() { Noidungtl = "FTP", Dapan = true },
                new() { Noidungtl = "TCP", Dapan = true },
                new() { Noidungtl = "NetBEUI", Dapan = false }
            }
        },
        new()
        {
            Noidung = "Các trạng thái của một tiến trình trong hệ điều hành bao gồm?", Dokho = 2, Mamonhoc = 732237, Machuong = 7, Nguoitao = "teacher002", Loaicauhoi = "multiple_choice", Trangthai = true,
            CauTraLois =
            {
                new() { Noidungtl = "New (Mới)", Dapan = true },
                new() { Noidungtl = "Ready (Sẵn sàng)", Dapan = true },
                new() { Noidungtl = "Running (Đang chạy)", Dapan = true },
                new() { Noidungtl = "Blocked (Bị khóa)", Dapan = true }
            }
        },
        new()
        {
            Noidung = "Những phương pháp nào được sử dụng để quản lý bộ nhớ trong hệ điều hành?", Dokho = 3, Mamonhoc = 732237, Machuong = 7, Nguoitao = "teacher002", Loaicauhoi = "multiple_choice", Trangthai = true,
            CauTraLois =
            {
                new() { Noidungtl = "Phân trang (Paging)", Dapan = true },
                new() { Noidungtl = "Phân đoạn (Segmentation)", Dapan = true },
                new() { Noidungtl = "Phân đoạn kết hợp phân trang", Dapan = true },
                new() { Noidungtl = "Lập lịch (Scheduling)", Dapan = false }
            }
        },
        new()
        {
            Noidung = "Vectơ pháp tuyến của mặt phẳng 2x - y + 3z - 1 = 0 có thể là những vectơ nào?", Dokho = 2, Mamonhoc = 570488, Machuong = 8, Nguoitao = "teacher001", Loaicauhoi = "multiple_choice", Trangthai = true,
            CauTraLois =
            {
                new() { Noidungtl = "(2, -1, 3)", Dapan = true },
                new() { Noidungtl = "(4, -2, 6)", Dapan = true },
                new() { Noidungtl = "(-2, 1, -3)", Dapan = true },
                new() { Noidungtl = "(2, 1, 3)", Dapan = false }
            }
        },
        new()
        {
            Noidung = "Những hàm số nào sau đây là hàm số chẵn?", Dokho = 2, Mamonhoc = 570488, Machuong = 8, Nguoitao = "teacher001", Loaicauhoi = "multiple_choice", Trangthai = true,
            CauTraLois =
            {
                new() { Noidungtl = "y = x^2", Dapan = true },
                new() { Noidungtl = "y = cos(x)", Dapan = true },
                new() { Noidungtl = "y = |x|", Dapan = true },
                new() { Noidungtl = "y = x^3 + x", Dapan = false }
            }
        },
        new()
        {
            Noidung = "Các loại dao động nào là dao động điều hòa?", Dokho = 2, Mamonhoc = 673119, Machuong = 9, Nguoitao = "teacher002", Loaicauhoi = "multiple_choice", Trangthai = true,
            CauTraLois =
            {
                new() { Noidungtl = "Dao động của con lắc lò xo khi bỏ qua ma sát.", Dapan = true },
                new() { Noidungtl = "Dao động của con lắc đơn khi góc lệch nhỏ và bỏ qua ma sát.", Dapan = true },
                new() { Noidungtl = "Dao động tắt dần.", Dapan = false },
                new() { Noidungtl = "Dao động cưỡng bức.", Dapan = false }
            }
        },
        new()
        {
            Noidung = "Đại lượng nào sau đây là đại lượng vectơ?", Dokho = 1, Mamonhoc = 673119, Machuong = 9, Nguoitao = "teacher001", Loaicauhoi = "multiple_choice", Trangthai = true,
            CauTraLois =
            {
                new() { Noidungtl = "Vận tốc", Dapan = true },
                new() { Noidungtl = "Lực", Dapan = true },
                new() { Noidungtl = "Gia tốc", Dapan = true },
                new() { Noidungtl = "Khối lượng", Dapan = false }
            }
        },
        new()
        {
            Noidung = "Trong C#, `interface` và `abstract class` có những điểm chung nào?", Dokho = 3, Mamonhoc = 734846, Machuong = 2, Nguoitao = "teacher001", Loaicauhoi = "multiple_choice", Trangthai = true,
            CauTraLois =
            {
                new() { Noidungtl = "Không thể tạo đối tượng trực tiếp từ chúng.", Dapan = true },
                new() { Noidungtl = "Có thể chứa các phương thức chưa được triển khai.", Dapan = true },
                new() { Noidungtl = "Dùng để định nghĩa một hợp đồng (contract) cho các lớp kế thừa.", Dapan = true },
                new() { Noidungtl = "Có thể chứa các trường (fields) private.", Dapan = false }
            }
        },
        new()
        {
            Noidung = "Các loại chỉ mục (index) trong cơ sở dữ liệu bao gồm?", Dokho = 3, Mamonhoc = 460154, Machuong = 5, Nguoitao = "teacher002", Loaicauhoi = "multiple_choice", Trangthai = true,
            CauTraLois =
            {
                new() { Noidungtl = "Clustered Index", Dapan = true },
                new() { Noidungtl = "Non-Clustered Index", Dapan = true },
                new() { Noidungtl = "Unique Index", Dapan = true },
                new() { Noidungtl = "Foreign Index", Dapan = false }
            }
        },
        new()
        {
            Noidung = "Những ứng dụng nào của cấu trúc dữ liệu \"Graph\"?", Dokho = 3, Mamonhoc = 227095, Machuong = 4, Nguoitao = "teacher002", Loaicauhoi = "multiple_choice", Trangthai = true,
            CauTraLois =
            {
                new() { Noidungtl = "Mô hình hóa mạng xã hội.", Dapan = true },
                new() { Noidungtl = "Tìm đường đi ngắn nhất trong bản đồ (GPS).", Dapan = true },
                new() { Noidungtl = "Phân tích mạng máy tính.", Dapan = true },
                new() { Noidungtl = "Thực hiện chức năng Undo/Redo trong trình soạn thảo.", Dapan = false }
            }
        },
        new()
        {
            Noidung = "Lớp địa chỉ IP nào dùng cho mục đích multicast?", Dokho = 3, Mamonhoc = 645403, Machuong = 6, Nguoitao = "teacher001", Loaicauhoi = "multiple_choice", Trangthai = true,
            CauTraLois =
            {
                new() { Noidungtl = "Lớp D (Class D)", Dapan = true },
                new() { Noidungtl = "Lớp A (Class A)", Dapan = false },
                new() { Noidungtl = "Lớp B (Class B)", Dapan = false },
                new() { Noidungtl = "Lớp C (Class C)", Dapan = false }
            }
        },
        new()
        {
            Noidung = "Các giải thuật lập lịch nào là giải thuật độc quyền (preemptive)?", Dokho = 2, Mamonhoc = 732237, Machuong = 7, Nguoitao = "teacher002", Loaicauhoi = "multiple_choice", Trangthai = true,
            CauTraLois =
            {
                new() { Noidungtl = "Round Robin (RR)", Dapan = true },
                new() { Noidungtl = "Shortest Remaining Time First (SRTF)", Dapan = true },
                new() { Noidungtl = "Priority Scheduling (Preemptive version)", Dapan = true },
                new() { Noidungtl = "First-Come, First-Served (FCFS)", Dapan = false }
            }
        },
        new()
        {
            Noidung = "Những ma trận nào sau đây có định thức bằng 0?", Dokho = 3, Mamonhoc = 570488, Machuong = 8, Nguoitao = "teacher001", Loaicauhoi = "multiple_choice", Trangthai = true,
            CauTraLois =
            {
                new() { Noidungtl = "Ma trận có một hàng hoặc một cột gồm toàn số 0.", Dapan = true },
                new() { Noidungtl = "Ma trận có hai hàng hoặc hai cột tỉ lệ với nhau.", Dapan = true },
                new() { Noidungtl = "Ma trận suy biến.", Dapan = true },
                new() { Noidungtl = "Ma trận đơn vị.", Dapan = false }
            }
        },
        #endregion

        #region Essay Questions with Model Answers
        new()
        {
            Noidung = "Sự khác biệt cốt lõi String/StringBuilder?",
            Dokho = 2, Mamonhoc = 734846, Machuong = 1, Nguoitao = "teacher001", Loaicauhoi = "essay", Trangthai = true,
            CauTraLois =
            {
                new() { Noidungtl = "String bất biến, StringBuilder khả biến.", Dapan = true }
            }
        },
        new()
        {
            Noidung = "Tính đa hình (polymorphism) là gì?",
            Dokho = 3, Mamonhoc = 734846, Machuong = 2, Nguoitao = "teacher001", Loaicauhoi = "essay", Trangthai = true,
            CauTraLois =
            {
                new() { Noidungtl = "Một đối tượng, nhiều hình thái.", Dapan = true }
            }
        },
        new()
        {
            Noidung = "Mục đích chính của ACID?",
            Dokho = 2, Mamonhoc = 460154, Machuong = 5, Nguoitao = "teacher002", Loaicauhoi = "essay", Trangthai = true,
            CauTraLois =
            {
                new() { Noidungtl = "Đảm bảo tính toàn vẹn giao dịch.", Dapan = true }
            }
        },
        new()
        {
            Noidung = "Nguyên tắc hoạt động của QuickSort?",
            Dokho = 3, Mamonhoc = 227095, Machuong = 4, Nguoitao = "teacher002", Loaicauhoi = "essay", Trangthai = true,
            CauTraLois =
            {
                new() { Noidungtl = "Sắp xếp bằng chia để trị.", Dapan = true }
            }
        },
        new()
        {
            Noidung = "Khác biệt hiệu năng Array/Linked List?",
            Dokho = 2, Mamonhoc = 227095, Machuong = 3, Nguoitao = "teacher002", Loaicauhoi = "essay", Trangthai = true,
            CauTraLois =
            {
                new() { Noidungtl = "Truy cập (Array) vs chèn/xóa (List).", Dapan = true }
            }
        },
        new()
        {
            Noidung = "Mục đích của chuẩn hóa CSDL?",
            Dokho = 3, Mamonhoc = 460154, Machuong = 5, Nguoitao = "teacher001", Loaicauhoi = "essay", Trangthai = true,
            CauTraLois =
            {
                new() { Noidungtl = "Giảm dư thừa, tăng tính nhất quán.", Dapan = true }
            }
        },
        new()
        {
            Noidung = "Cơ chế truyền dữ liệu OSI?",
            Dokho = 2, Mamonhoc = 645403, Machuong = 6, Nguoitao = "teacher001", Loaicauhoi = "essay", Trangthai = true,
            CauTraLois =
            {
                new() { Noidungtl = "Đóng gói khi gửi, mở gói khi nhận.", Dapan = true }
            }
        },
        new()
        {
            Noidung = "So sánh vắn tắt TCP và UDP?",
            Dokho = 2, Mamonhoc = 645403, Machuong = 6, Nguoitao = "teacher001", Loaicauhoi = "essay", Trangthai = true,
            CauTraLois =
            {
                new() { Noidungtl = "TCP tin cậy, UDP tốc độ.", Dapan = true }
            }
        },
        new()
        {
            Noidung = "Phân mảnh bộ nhớ là gì?",
            Dokho = 3, Mamonhoc = 732237, Machuong = 7, Nguoitao = "teacher002", Loaicauhoi = "essay", Trangthai = true,
            CauTraLois =
            {
                new() { Noidungtl = "Bộ nhớ trống bị chia nhỏ.", Dapan = true }
            }
        },
        new()
        {
            Noidung = "Vai trò chính của bộ nhớ ảo?",
            Dokho = 2, Mamonhoc = 732237, Machuong = 7, Nguoitao = "teacher002", Loaicauhoi = "essay", Trangthai = true,
            CauTraLois =
            {
                new() { Noidungtl = "Mở rộng không gian bộ nhớ.", Dapan = true }
            }
        },
        new()
        {
            Noidung = "Quy tắc tìm max/min trên đoạn?",
            Dokho = 2, Mamonhoc = 570488, Machuong = 8, Nguoitao = "teacher001", Loaicauhoi = "essay", Trangthai = true,
            CauTraLois =
            {
                new() { Noidungtl = "So sánh f(a), f(b), f(cực trị).", Dapan = true }
            }
        },
        new()
        {
            Noidung = "Ý nghĩa hình học định lý Lagrange?",
            Dokho = 3, Mamonhoc = 570488, Machuong = 8, Nguoitao = "teacher001", Loaicauhoi = "essay", Trangthai = true,
            CauTraLois =
            {
                new() { Noidungtl = "Tồn tại tiếp tuyến song song cát tuyến.", Dapan = true }
            }
        },
        new()
        {
            Noidung = "Điều kiện xảy ra hiện tượng quang điện?",
            Dokho = 2, Mamonhoc = 673119, Machuong = 9, Nguoitao = "teacher002", Loaicauhoi = "essay", Trangthai = true,
            CauTraLois =
            {
                new() { Noidungtl = "Tần số ánh sáng đủ lớn.", Dapan = true }
            }
        },
        new()
        {
            Noidung = "Biểu thức cốt lõi định luật II Newton?",
            Dokho = 1, Mamonhoc = 673119, Machuong = 9, Nguoitao = "teacher001", Loaicauhoi = "essay", Trangthai = true,
            CauTraLois =
            {
                new() { Noidungtl = "F = m * a", Dapan = true }
            }
        },
        new()
        {
            Noidung = "Cơ chế hoạt động của Garbage Collector?",
            Dokho = 3, Mamonhoc = 734846, Machuong = 1, Nguoitao = "teacher001", Loaicauhoi = "essay", Trangthai = true,
            CauTraLois =
            {
                new() { Noidungtl = "Đánh dấu, sau đó quét rác.", Dapan = true }
            }
        },
        new()
        {
            Noidung = "Nguyên tắc thuật toán Dijkstra?",
            Dokho = 3, Mamonhoc = 227095, Machuong = 4, Nguoitao = "teacher002", Loaicauhoi = "essay", Trangthai = true,
            CauTraLois =
            {
                new() { Noidungtl = "Tham lam, chọn đỉnh gần nhất.", Dapan = true }
            }
        },
        new()
        {
            Noidung = "Chức năng chính của DNS?",
            Dokho = 2, Mamonhoc = 645403, Machuong = 6, Nguoitao = "teacher001", Loaicauhoi = "essay", Trangthai = true,
            CauTraLois =
            {
                new() { Noidungtl = "Phân giải tên miền ra IP.", Dapan = true }
            }
        },
        new()
        {
            Noidung = "Race Condition là lỗi gì?",
            Dokho = 3, Mamonhoc = 732237, Machuong = 7, Nguoitao = "teacher002", Loaicauhoi = "essay", Trangthai = true,
            CauTraLois =
            {
                new() { Noidungtl = "Lỗi truy cập tài nguyên chung.", Dapan = true }
            }
        },
        new()
        {
            Noidung = "Quy tắc Sarrus dùng để làm gì?",
            Dokho = 2, Mamonhoc = 570488, Machuong = 8, Nguoitao = "teacher001", Loaicauhoi = "essay", Trangthai = true,
            CauTraLois =
            {
                new() { Noidungtl = "Tính định thức ma trận 3x3.", Dapan = true }
            }
        },
        #endregion
    };

                await _context.CauHois.AddRangeAsync(cauHoisAndTraLois);
                await _context.SaveChangesAsync();
            }

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
            await _context.SaveChangesAsync();
        }
    }
}