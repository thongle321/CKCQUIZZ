using CKCQUIZZ.Server.Viewmodels.Auth;
using Microsoft.AspNetCore.Identity;
using System.Threading.Tasks;

namespace CKCQUIZZ.Server.Interfaces
{
    public interface IUserProfileService
    {
        Task<CurrentUserProfileDTO?> GetUserProfileAsync(string userId);
        Task<IdentityResult> UpdateUserProfileAsync(string userId, UpdateUserProfileDTO model);
    }
}