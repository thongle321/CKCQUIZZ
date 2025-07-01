using Microsoft.AspNetCore.SignalR;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Authorization;
using CKCQUIZZ.Server.Viewmodels.DeThi;

namespace CKCQUIZZ.Server.Hubs
{
    public interface IExamHubClient
    {
        Task ReceiveExam(ExamForClassDto exam);
        Task ReceiveExamStatusUpdate(int made, string newStatus);
    }

    [Authorize]
    public sealed class ExamHub : Hub<IExamHubClient>
    {

    }
}