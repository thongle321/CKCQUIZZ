using System.Collections.Concurrent;
using CKCQUIZZ.Server.Interfaces;

namespace CKCQUIZZ.Server.Services
{
    public class ActiveUserService : IActiveUserService
    {
        private readonly ConcurrentDictionary<string, bool> _activeUsers = new();

        public bool IsUserActive(string userId)
        {
            return _activeUsers.ContainsKey(userId);
        }

        public void AddUser(string userId)
        {
            _activeUsers.TryAdd(userId, true);
        }

        public void RemoveUser(string userId)
        {
            _activeUsers.TryRemove(userId, out _);
        }
    }
}