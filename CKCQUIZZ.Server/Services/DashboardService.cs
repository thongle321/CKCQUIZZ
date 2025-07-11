using CKCQUIZZ.Server.Data;
using CKCQUIZZ.Server.Interfaces;
using CKCQUIZZ.Server.Models;
using CKCQUIZZ.Server.Viewmodels.Dashboard;
using Microsoft.AspNetCore.Identity;
using Microsoft.EntityFrameworkCore;
using System;
using System.Linq;
using System.Threading.Tasks;
using System.Collections.Generic;

namespace CKCQUIZZ.Server.Services
{
    public class DashboardService(CkcquizzContext _context, UserManager<NguoiDung> _userManager) : IDashboardService
    {
        public async Task<int> GetTotalUsersAsync()
        {
            return await _userManager.Users.CountAsync();
        }
        public async Task<int> GetTotalExamsAsync()
        {
            return await _context.DeThis.CountAsync();
        }
        public async Task<int> GetTotalQuestionsAsync()
        {
            return await _context.CauHois.CountAsync();
        }
        public async Task<int> GetTotalStudentsAsync()
        {
            var usersInRole = await _userManager.GetUsersInRoleAsync("Student");
            return usersInRole.Count;
        }
        public async Task<int> GetTotalCompletedExamsAsync()
        {
            return await _context.KetQuas.CountAsync(kq => kq.Thoigianvaothi != null && kq.Thoigianlambai != null);
        }
        public async Task<int> GetTotalActiveExamsAsync()
        {
            return await _context.KetQuas.CountAsync(kq => kq.Thoigianvaothi != null && kq.Thoigianlambai == null);
        }
        public async Task<DashboardStatisticsDto> GetDashboardStatistics()
        {
            return new DashboardStatisticsDto
            {
                TotalUsers = await GetTotalUsersAsync(),
                TotalExams = await GetTotalExamsAsync(),
                TotalQuestions = await GetTotalQuestionsAsync(),
                TotalStudents = await GetTotalStudentsAsync(),
                CompletedExams = await GetTotalCompletedExamsAsync(),
                ActiveExams = await GetTotalActiveExamsAsync(),
                MonthlyUserRegistrations = await GetMonthlyUserRegistrationsAsync(),
                MonthlyStudentRegistrations = await GetMonthlyStudentRegistrationsAsync(),
                MonthlyTeacherRegistrations = await GetMonthlyTeacherRegistrationsAsync(),
                ExamCompletionRates = await GetExamCompletionRatesAsync()
            };
        }

        public async Task<Dictionary<string, int>> GetMonthlyUserRegistrationsAsync()
        {
            var groupedData = await _userManager.Users
                .GroupBy(u => new { Year = u.Ngaythamgia.Year, Month = u.Ngaythamgia.Month })
                .Select(g => new { Year = g.Key.Year, Month = g.Key.Month, Count = g.Count() })
                .OrderBy(x => x.Year).ThenBy(x => x.Month)
                .ToListAsync();

            return groupedData.ToDictionary(
                x => $"{x.Year}-{x.Month:00}",
                x => x.Count
            );
        }

        public async Task<Dictionary<string, int>> GetMonthlyStudentRegistrationsAsync()
        {
            var students = await _userManager.GetUsersInRoleAsync("Student");
            var groupedData = students.AsQueryable()
                .GroupBy(u => new { Year = u.Ngaythamgia.Year, Month = u.Ngaythamgia.Month })
                .Select(g => new { Year = g.Key.Year, Month = g.Key.Month, Count = g.Count() })
                .OrderBy(x => x.Year).ThenBy(x => x.Month)
                .ToList();

            return groupedData.ToDictionary(
                x => $"{x.Year}-{x.Month:00}",
                x => x.Count
            );
        }

        public async Task<Dictionary<string, int>> GetMonthlyTeacherRegistrationsAsync()
        {
            var teachers = await _userManager.GetUsersInRoleAsync("Teacher");
            var groupedData = teachers.AsQueryable()
                .GroupBy(u => new { Year = u.Ngaythamgia.Year, Month = u.Ngaythamgia.Month })
                .Select(g => new { Year = g.Key.Year, Month = g.Key.Month, Count = g.Count() })
                .OrderBy(x => x.Year).ThenBy(x => x.Month)
                .ToList();

            return groupedData.ToDictionary(
                x => $"{x.Year}-{x.Month:00}",
                x => x.Count
            );
        }

        public async Task<Dictionary<string, int>> GetExamCompletionRatesAsync()
        {
            var totalCompletedExams = await _context.KetQuas.CountAsync(kq => kq.Thoigianlambai != null);
            var passedExams = await _context.KetQuas.CountAsync(kq => kq.Thoigianlambai != null && kq.Diemthi >= 5); 
            var failedExams = totalCompletedExams - passedExams;

            return new Dictionary<string, int>
            {
                { "Hoàn thành", passedExams },
                { "Chưa hoàn thành", failedExams }
            };
        }
    }
}