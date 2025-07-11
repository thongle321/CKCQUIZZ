using CKCQUIZZ.Server.Interfaces;
using CKCQUIZZ.Server.Viewmodels.Dashboard;
using Microsoft.AspNetCore.Mvc;
using System.Threading.Tasks;
using System.Collections.Generic;

namespace CKCQUIZZ.Server.Controllers
{
    public class DashboardController(IDashboardService _dashboardService) : BaseController
    {
        [HttpGet]
        public async Task<ActionResult<DashboardStatisticsDto>> GetDashboardStatistics()
        {
            var statistics = await _dashboardService.GetDashboardStatistics();
            return Ok(statistics);
        }
    }
}