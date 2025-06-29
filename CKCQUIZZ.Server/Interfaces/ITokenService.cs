using System.Security.Claims;
using CKCQUIZZ.Server.Models;
using CKCQUIZZ.Server.Viewmodels.Token;

namespace CKCQUIZZ.Server.Interfaces
{
    public interface ITokenService
    {
        string CreateToken(NguoiDung user);
        string GenerateRefreshToken();
        Task<string> GenerateAndSaveRefreshTokenAsync(NguoiDung user, bool rememberMe = false);
        Task<TokenResponse> CreateTokenResponse(NguoiDung? user, bool rememberMe);
        Task<TokenResponse?> RefreshTokensAsync(RefreshTokenRequest request);
        void SetTokenInsideCookie(TokenResponse tokenResponse, HttpContext context, bool rememberMe);
        void ClearTokenFromCookie(HttpContext context);
        Task<NguoiDung?> GetUserByRefreshTokenAsync(string refreshToken);
    }
}
