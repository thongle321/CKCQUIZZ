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

            return await _tokenService.CreateTokenResponse(user);
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
        public async Task<TokenResponse?> LoginWithGoogleAsync(ClaimsPrincipal? claimsPrincipal)
        {
            if (claimsPrincipal is null) return null;

            var providerKey = claimsPrincipal.FindFirstValue(ClaimTypes.NameIdentifier);
            if(providerKey is null)
            {
                return null;
            }
            var info = new UserLoginInfo("Google", providerKey, "Google");

            var user = await _userManager.FindByLoginAsync(info.LoginProvider, info.ProviderKey);
            if (user is not null)
            {
                return await _tokenService.CreateTokenResponse(user);
            }

            var email = claimsPrincipal.FindFirstValue(ClaimTypes.Email);
            if (string.IsNullOrEmpty(email)) return null;

            if (!email.EndsWith("@caothang.edu.vn", StringComparison.OrdinalIgnoreCase))
            {
                return null;
            }

            user = await _userManager.FindByEmailAsync(email);

            if (user is not null)
            {

                var existingRoles = await _userManager.GetRolesAsync(user);
                if (!existingRoles.Any())
                {
                    var addToRoleResult = await _userManager.AddToRoleAsync(user, "Student");
                    if (!addToRoleResult.Succeeded)
                    {
                        var roleErrors = string.Join(", ", addToRoleResult.Errors.Select(e => e.Description));
                        return null;
                    }
                }

                await _userManager.AddLoginAsync(user, info);
            }
            else
            {
                var newUser = new NguoiDung
                {
                    UserName = email,
                    Email = email,
                    Hoten = claimsPrincipal.FindFirstValue(ClaimTypes.Name) ?? string.Empty,
                    Trangthai = true,
                    EmailConfirmed = true
                };

                var createResult = await _userManager.CreateAsync(newUser);
                if (!createResult.Succeeded)
                {
                    return null;
                }

                user = newUser;

                var addToRoleResult = await _userManager.AddToRoleAsync(user, "Student");
                if (!addToRoleResult.Succeeded)
                {
                    return null;
                }

                await _userManager.AddLoginAsync(user, info);
            }


            return await _tokenService.CreateTokenResponse(user);
        }
    }
}