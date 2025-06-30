using Microsoft.AspNetCore.SignalR;
namespace CKCQUIZZ.Server.Hubs
{ 
    public sealed class NotificationHub : Hub
    {
        public async Task SendNotification(CKCQUIZZ.Server.Viewmodels.ThongBao.ThongBaoGetAnnounceDTO notification)
        {
            await Clients.All.SendAsync("ReceiveNotification", notification);
        }
    }

}