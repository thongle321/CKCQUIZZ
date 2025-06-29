using System.Runtime.InteropServices;
using System.Security.Claims;
using CKCQUIZZ.Server.Interfaces;
using CKCQUIZZ.Server.Models;
using CKCQUIZZ.Server.Viewmodels;
using CKCQUIZZ.Server.Viewmodels.Auth;
using CKCQUIZZ.Server.Viewmodels.Token;
using Microsoft.AspNetCore.Http.HttpResults;
using Microsoft.AspNetCore.Identity;
using Microsoft.AspNetCore.Mvc;

namespace CKCQUIZZ.Server.Services
{
    public class AuthService(UserManager<NguoiDung> _userManager, SignInManager<NguoiDung> _signInManager, ITokenService _tokenService, IEmailSender _emailSender) : IAuthService
    {
        public async Task<TokenResponse?> SignInAsync(SignInDTO request)
        {
            var user = await _userManager.FindByEmailAsync(request.Email);
            if (user is null)
            {
                return null;
            }
            var result = await _signInManager.CheckPasswordSignInAsync(user, request.Password, false);
            if (!result.Succeeded)
            {
                return null;
            }

            return await _tokenService.CreateTokenResponse(user, request.RememberMe);
        }
        public async Task<string?> ForgotPasswordAsync(ForgotPasswordDTO request)
        {

            var user = await _userManager.FindByEmailAsync(request.Email);

            if (user is null)
            {
                return null;
            }

            string otp = await _userManager.GenerateTwoFactorTokenAsync(user, TokenOptions.DefaultEmailProvider);

            var emailSubject = "Mã đặt lại mật khẩu của bạn";
            var emailMessage = $"""
                <h2>Xin chào {user.Email},<br/><br/></h2>" 
                <h2>Mã đặt lại mật khẩu của bạn là: <strong>{otp}</strong><br/><br/></h2>
                <h2>Mã này sẽ hết hạn sau 15 phút.<br/><br/></h2>
                <h2>Nếu bạn không yêu cầu đặt lại mật khẩu, vui lòng bỏ qua email này.</h2>
            """;

            await _emailSender.SendEmailAsync(user.Email!, emailSubject, emailMessage);

            return user.Email;

        }
        public async Task<(VerifyOtpStatus Status, string? PasswordResetToken, string? Email)> VerifyOtpAsync(VerifyOtpDTO request)
        {
            var user = await _userManager.FindByEmailAsync(request.Email);
            if (user is null)
            {
                return (VerifyOtpStatus.EmailNotFound, null, null);
            }
            var isValidOtp = await _userManager.VerifyTwoFactorTokenAsync(user, TokenOptions.DefaultEmailProvider, request.Otp);

            if (!isValidOtp)
            {
                return (VerifyOtpStatus.InvalidOtp, null, null);
            }
            var passwordResetToken = await _userManager.GeneratePasswordResetTokenAsync(user);
            return (VerifyOtpStatus.Success, passwordResetToken, user.Email);
        }
        public async Task<(bool IsSuccess, string Message)> ResetPasswordAsync(ResetPasswordDTO request)
        {
            var user = await _userManager.FindByEmailAsync(request.Email);
            if (user is null)
            {
                return (false, "Yêu cầu đặt lại mật khẩu không hợp lệ hoặc đã hết hạn.");
            }

            var resetPassResult = await _userManager.ResetPasswordAsync(user, request.Token, request.NewPassword);

            if (resetPassResult.Succeeded)
            {
                return (true, "Mật khẩu đã được đặt lại thành công.");
            }

            var errorMsg = resetPassResult.Errors.FirstOrDefault()?.Description
                           ?? "Không thể đặt lại mật khẩu. Token có thể không hợp lệ hoặc mật khẩu không đáp ứng yêu cầu.";

            return (false, errorMsg);
        }
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

            var tokenResponse = await _tokenService.CreateTokenResponse(user, true); // Đăng nhập Google luôn ghi nhớ
            _tokenService.SetTokenInsideCookie(tokenResponse, httpContext, true); // Đăng nhập Google luôn ghi nhớ
        }
    }
}