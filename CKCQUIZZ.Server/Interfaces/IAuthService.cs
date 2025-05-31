using System.Security.Claims;

namespace CKCQUIZZ.Server.Interfaces
{
    public interface IAuthService
    {
        Task LoginWithGoogleAsync(ClaimsPrincipal? claimsPrincipal, HttpContext httpContext);
    }
}