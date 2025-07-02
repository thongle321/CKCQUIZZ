using CKCQUIZZ.Server.Viewmodels.Dashboard;
using System.Threading.Tasks;

namespace CKCQUIZZ.Server.Interfaces
{
    public interface IDashboardService
    {
        Task<int> GetTotalUsersAsync();
        Task<int> GetTotalExamsAsync();
        Task<int> GetTotalQuestionsAsync();
        Task<int> GetTotalStudentsAsync();   
        Task<int> GetTotalCompletedExamsAsync();
        Task<int> GetTotalActiveExamsAsync();
        Task<DashboardStatisticsDto> GetDashboardStatistics();
    }
}