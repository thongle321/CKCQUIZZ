using CKCQUIZZ.Server.Models;
using CKCQUIZZ.Server.Viewmodels.Token;

namespace CKCQUIZZ.Server.Interfaces
{
    public interface ITokenService
    {
        string CreateToken(NguoiDung user);
        string GenerateRefreshToken();
        Task<string> GenerateAndSaveRefreshTokenAsync(NguoiDung user);
        Task<TokenResponse> CreateTokenResponse(NguoiDung? user);
        Task<TokenResponse?> RefreshTokensAsync(RefreshTokenRequest request);
        void SetTokenInsideCookie(TokenResponse tokenResponse, HttpContext context);
        void ClearTokenFromCookie(HttpContext context);
    }
}
