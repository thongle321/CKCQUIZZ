using Microsoft.AspNetCore.SignalR;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Authorization;
using CKCQUIZZ.Server.Viewmodels.DeThi;

namespace CKCQUIZZ.Server.Hubs
{
    public interface IExamHubClient
    {
        Task ReceiveExam(ExamForClassDto exam);
        Task UpdateExamStatus(object payload);
    }

    [Authorize]
    public sealed class ExamHub : Hub<IExamHubClient>
    {

    }
}