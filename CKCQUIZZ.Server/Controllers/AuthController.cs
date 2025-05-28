using System.IdentityModel.Tokens.Jwt;
using System.Security.Claims;
using System.Text;
using CKCQUIZZ.Server.Interfaces;
using CKCQUIZZ.Server.Models;
using CKCQUIZZ.Server.Viewmodels;
using CKCQUIZZ.Server.Viewmodels.Auth;
using CKCQUIZZ.Server.Viewmodels.Token;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Identity;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Caching.Memory;
using Microsoft.IdentityModel.Tokens;

namespace CKCQUIZZ.Server.Controllers
{
    [ApiController]
    [Route("[controller]")]
    public class AuthController(UserManager<NguoiDung> _userManager, SignInManager<NguoiDung> _signInManager, ITokenService _tokenService, IEmailSender _emailSender) : ControllerBase
    {

        [HttpPost("signin")]
        public async Task<ActionResult<TokenResponse>> SignIn(SignInDTO request)
        {
            if (!ModelState.IsValid)
            {
                return BadRequest(ModelState);
            }
            var user = await _userManager.FindByEmailAsync(request.Email);
            if (user == null)
            {
                return Unauthorized("Email không đúng");
            }
            var result = await _signInManager.CheckPasswordSignInAsync(user, request.Password, false);
            if (!result.Succeeded)
            {
                return Unauthorized("Email không đúng hoặc sai mật khẩu");
            }

            var tokenResponse = await _tokenService.CreateTokenResponse(user);
            _tokenService.SetTokenInsideCookie(tokenResponse, HttpContext);
            return Ok();
        }
        [HttpPost("forgotpassword")]
        [AllowAnonymous]
        public async Task<IActionResult> ForgotPassword(ForgotPasswordDTO request)
        {
            if (!ModelState.IsValid)
            {
                return BadRequest(ModelState);
            }

            var user = await _userManager.FindByEmailAsync(request.Email);

            if (user is null)
            {
                return Unauthorized("Email không tồn tại");
            }

            string otp = await _userManager.GenerateTwoFactorTokenAsync(user, TokenOptions.DefaultEmailProvider);

            var emailSubject = "Mã đặt lại mật khẩu của bạn";
            var emailMessage = $"<h2>Xin chào {user.Email},<br/><br/></h2>" +
                               $"<h2>Mã đặt lại mật khẩu của bạn là: <strong>{otp}</strong><br/><br/></h2>" +
                               $"<h2>Mã này sẽ hết hạn sau 15 phút.<br/><br/></h2>" +
                               $"<h2>Nếu bạn không yêu cầu đặt lại mật khẩu, vui lòng bỏ qua email này.</h2>";

            try
            {
                await _emailSender.SendEmailAsync(user.Email ?? default!, emailSubject, emailMessage);
            }
            catch (Exception ex)
            {
                Console.WriteLine(ex.Message);
            }
            return Ok(new
            {
                request.Email,
            });
        }
        [HttpPost("verifyotp")]
        [AllowAnonymous]
        public async Task<IActionResult> VerifyOtp(VerifyOtpDTO request)
        {
            if (!ModelState.IsValid)
            {
                return BadRequest(ModelState);
            }

            var user = await _userManager.FindByEmailAsync(request.Email);
            if (user is null)
            {
                return BadRequest(new { Message = "Không tìm thấy email hợp lệ" });
            }

            var isValidOtp = await _userManager.VerifyTwoFactorTokenAsync(user, TokenOptions.DefaultEmailProvider, request.Otp);

            if (isValidOtp)
            {

                var passwordResetToken = await _userManager.GeneratePasswordResetTokenAsync(user);


                return Ok(new
                {
                    Message = "Xác thực OTP thành công.",
                    Email = user.Email,
                    PasswordResetToken = passwordResetToken
                });
            }
            else
            {
                return BadRequest(new { Message = "Mã OTP không hợp lệ hoặc đã hết hạn." });
            }
        }
        [HttpPost("resetpassword")]
        [AllowAnonymous]
        public async Task<IActionResult> ResetPassword(ResetPasswordDTO request)
        {
            if (!ModelState.IsValid)
            {
                return BadRequest(ModelState);
            }

            var user = await _userManager.FindByEmailAsync(request.Email);
            if (user is null)
            {
                return BadRequest(new { Message = "Yêu cầu đặt lại mật khẩu không hợp lệ hoặc đã hết hạn." });
            }


            var resetPassResult = await _userManager.ResetPasswordAsync(user, request.Token, request.NewPassword);

            if (resetPassResult.Succeeded)
            {
                return Ok(new { Message = "Mật khẩu đã được đặt lại thành công." });
            }

            var errors = new List<string>();
            foreach (var error in resetPassResult.Errors)
            {
                errors.Add(error.Description);
            }
            return BadRequest(new { Message = errors.FirstOrDefault() ?? "Không thể đặt lại mật khẩu. Token có thể không hợp lệ hoặc mật khẩu không đáp ứng yêu cầu." });
        }

        [Authorize]
        [HttpGet]
        public IActionResult AuthenticatedEndpoint()
        {
            return Ok("Bạn đã được xác thực");
        }

        [Authorize(Roles = "Admin")]
        [HttpGet("admin")]
        public IActionResult AdminEndPoint()
        {
            return Ok("Bạn đã được xác thực");
        }

        [HttpPost("refresh-token")]
        public async Task<ActionResult<TokenResponse>> RefreshToken()
        {
            HttpContext.Request.Cookies.TryGetValue("accessToken", out var accessToken);
            HttpContext.Request.Cookies.TryGetValue("refreshToken", out var refreshToken);
            var handler = new JwtSecurityTokenHandler();
            var jwtToken = handler.ReadJwtToken(accessToken ?? string.Empty);
            var userId = jwtToken.Claims.FirstOrDefault(c => c.Type == JwtRegisteredClaimNames.Sub)?.Value;

            if (userId == null || refreshToken == null)
            {
                return Unauthorized("Token không hợp lệ");
            }

            var refreshRequest = new RefreshTokenRequest
            {
                Id = userId,
                RefreshToken = refreshToken
            };

            var result = await _tokenService.RefreshTokensAsync(refreshRequest);

            if (result == null || result.AccessToken == null || result.RefreshToken == null)
            {
                return Unauthorized("Token không hợp lệ");
            }

            _tokenService.SetTokenInsideCookie(result, HttpContext);

            return Ok(result);
        }
        
    }
}
