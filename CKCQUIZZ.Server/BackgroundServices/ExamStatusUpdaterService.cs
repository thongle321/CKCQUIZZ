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
                        .AsNoTracking()
                        .ToListAsync(stoppingToken);

                    foreach (var exam in activeExams)
                    {
                        string currentStatus = "";
                        if (exam.Thoigiantbatdau.HasValue && now < exam.Thoigiantbatdau.Value)
                        {
                            currentStatus = "SapDienRa";
                        }
                        else if (exam.Thoigianketthuc.HasValue && now > exam.Thoigianketthuc.Value)
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

                        if (currentStatus != "DaKetThuc" && studentIdsInClasses.Count > 0)
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