using CKCQUIZZ.Server.Interfaces;
using CKCQUIZZ.Server.Viewmodels.ThongBao;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.SignalR;
namespace CKCQUIZZ.Server.Hubs
{
    public interface INotificationHubClient
    {
        Task ReceiveNotification(ThongBaoGetAnnounceDTO notification);
        Task NotifyLogin(string message);
    }

    [Authorize]
    public sealed class NotificationHub(IActiveUserService activeUserService) : Hub<INotificationHubClient>
    {
        public override async Task OnConnectedAsync()
        {
            var userId = Context.User?.FindFirst(System.Security.Claims.ClaimTypes.NameIdentifier)?.Value;
            if (!string.IsNullOrEmpty(userId))
            {
                activeUserService.AddUser(userId);
                await Groups.AddToGroupAsync(Context.ConnectionId, userId);
            }
            await base.OnConnectedAsync();
        }

        public override async Task OnDisconnectedAsync(Exception? exception)
        {
            var userId = Context.User?.FindFirst(System.Security.Claims.ClaimTypes.NameIdentifier)?.Value;
            if (!string.IsNullOrEmpty(userId))
            {
                activeUserService.RemoveUser(userId);
            }
            await base.OnDisconnectedAsync(exception);
        }

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