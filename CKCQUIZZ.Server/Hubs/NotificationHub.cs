using CKCQUIZZ.Server.Viewmodels.ThongBao;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.SignalR;
namespace CKCQUIZZ.Server.Hubs
{
    public interface INotificationHubClient
    {
        Task ReceiveNotification(ThongBaoGetAnnounceDTO notification);
    }

    [Authorize]
    public sealed class NotificationHub : Hub<INotificationHubClient>
    {
        public async Task JoinClassGroup(string classId)
        {
            await Groups.AddToGroupAsync(Context.ConnectionId, $"class-{classId}");
        }

        public async Task LeaveClassGroup(string classId)
        {
            await Groups.RemoveFromGroupAsync(Context.ConnectionId, $"class-{classId}");
        }
    }

}