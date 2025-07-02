using CKCQUIZZ.Server.Data;
using CKCQUIZZ.Server.Interfaces;
using CKCQUIZZ.Server.Models;
using CKCQUIZZ.Server.Viewmodels.Dashboard;
using Microsoft.AspNetCore.Identity;
using Microsoft.EntityFrameworkCore;
using System;
using System.Linq;
using System.Threading.Tasks;

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
            };
        }
    }
}