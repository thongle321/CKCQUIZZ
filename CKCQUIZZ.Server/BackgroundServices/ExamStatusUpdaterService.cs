using Microsoft.Extensions.Hosting;
using Microsoft.Extensions.DependencyInjection;
using System;
using System.Threading;
using System.Threading.Tasks;
using CKCQUIZZ.Server.Interfaces;
using Microsoft.AspNetCore.SignalR;
using CKCQUIZZ.Server.Hubs;
using CKCQUIZZ.Server.Viewmodels.DeThi;
using System.Linq;
using Microsoft.EntityFrameworkCore;
using CKCQUIZZ.Server.Data;
using CKCQUIZZ.Server.Models;

namespace CKCQUIZZ.Server.BackgroundServices
{
    public class ExamStatusUpdaterService(IServiceProvider _serviceProvider, IHubContext<ExamHub, IExamHubClient> _examHubContext) : BackgroundService
    {


        protected override async Task ExecuteAsync(CancellationToken stoppingToken)
        {
            while (!stoppingToken.IsCancellationRequested)
            {
                using (var scope = _serviceProvider.CreateScope())
                {
                    var deThiService = scope.ServiceProvider.GetRequiredService<IDeThiService>();
                    var context = scope.ServiceProvider.GetRequiredService<CkcquizzContext>();

                    var now = DateTime.UtcNow;

                    var activeExams = await context.DeThis
                        .Where(d => d.Trangthai == true && (d.Thoigiantbatdau.HasValue || d.Thoigianketthuc.HasValue))
                        .Include(d => d.Malops)
                        .ToListAsync(stoppingToken);

                    foreach (var exam in activeExams)
                    {
                        string currentStatus = "";
                        if (exam.Thoigiantbatdau.HasValue && now < DateTime.SpecifyKind(exam.Thoigiantbatdau.Value, DateTimeKind.Local).ToUniversalTime())
                        {
                            currentStatus = "SapDienRa";
                        }
                        else if (exam.Thoigianketthuc.HasValue && now > DateTime.SpecifyKind(exam.Thoigianketthuc.Value, DateTimeKind.Local).ToUniversalTime())
                        {
                            currentStatus = "DaKetThuc";
                        }
                        else
                        {
                            currentStatus = "DangDienRa";
                        }


                        var assignedClassIds = exam.Malops.Select(l => l.Malop).ToList();
                        var studentIdsInClasses = await context.ChiTietLops
                            .Where(ctl => assignedClassIds.Contains(ctl.Malop) && ctl.Trangthai == true)
                            .Select(ctl => ctl.Manguoidung)
                            .Distinct()
                            .ToListAsync(stoppingToken);

                        if (studentIdsInClasses.Count > 0)
                        {
                            await _examHubContext.Clients.Users(studentIdsInClasses).ReceiveExamStatusUpdate(exam.Made, currentStatus);
                        }
                    }
                }

                await Task.Delay(TimeSpan.FromSeconds(30), stoppingToken);
            }
        }
    }
}