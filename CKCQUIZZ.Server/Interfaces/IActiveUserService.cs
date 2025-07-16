namespace CKCQUIZZ.Server.Interfaces
{
    public interface IActiveUserService
    {
        bool IsUserActive(string userId);
        void AddUser(string userId);
        void RemoveUser(string userId);
    }
}