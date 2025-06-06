using System.Security.Claims;
using CKCQUIZZ.Server.Viewmodels;
using CKCQUIZZ.Server.Viewmodels.Auth;
using CKCQUIZZ.Server.Viewmodels.Token;
using Microsoft.AspNetCore.Mvc;

namespace CKCQUIZZ.Server.Interfaces
{
    public interface IAuthService
    {
        Task<TokenResponse?> SignInAsync(SignInDTO request);
        Task<string?> ForgotPasswordAsync(ForgotPasswordDTO request);
        Task<(VerifyOtpStatus Status, string? PasswordResetToken, string? Email)> VerifyOtpAsync(VerifyOtpDTO request);
        Task<(bool IsSuccess, string Message)> ResetPasswordAsync(ResetPasswordDTO request);
        Task LoginWithGoogleAsync(ClaimsPrincipal? claimsPrincipal, HttpContext httpContext);
    }
}