using System.Runtime.InteropServices;
using System.Security.Claims;
using CKCQUIZZ.Server.Interfaces;
using CKCQUIZZ.Server.Models;
using Microsoft.AspNetCore.Http.HttpResults;
using Microsoft.AspNetCore.Identity;

namespace CKCQUIZZ.Server.Services
{
    public class AuthService(UserManager<NguoiDung> _userManager, ITokenService _tokenService) : IAuthService
    {
        public async Task LoginWithGoogleAsync(ClaimsPrincipal? claimsPrincipal, HttpContext httpContext)
        {
            if (claimsPrincipal is null)
            {
                throw new ArgumentNullException(nameof(claimsPrincipal), "Khong tim thay principal");
            }
            var email = claimsPrincipal.FindFirstValue(ClaimTypes.Email) ?? throw new InvalidOperationException("Khong tim thay email trong google ClaimsPrincipal");
            var user = await _userManager.FindByEmailAsync(email);
            if (user is null)
            {
                var newUser = new NguoiDung
                {
                    UserName = email,
                    Email = email,
                    Hoten = claimsPrincipal.FindFirstValue(ClaimTypes.Name) ?? string.Empty,
                    Trangthai = true,
                    EmailConfirmed = true
                };
                var result = await _userManager.CreateAsync(newUser);
                if (!result.Succeeded)
                {
                    throw new InvalidOperationException("Khong the tao user");
                }
                user = newUser;
            }
            var info = new UserLoginInfo("Google", claimsPrincipal.FindFirstValue(ClaimTypes.Email) ?? string.Empty, "Google");

            var loginResult = await _userManager.AddLoginAsync(user, info);

            if (!loginResult.Succeeded)
            {
                throw new InvalidOperationException("Khong the login user");
            }

            var tokenResponse = await _tokenService.CreateTokenResponse(user);
            _tokenService.SetTokenInsideCookie(tokenResponse, httpContext);
        }
    }
}