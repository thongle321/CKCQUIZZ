using System.IdentityModel.Tokens.Jwt;
using System.Security.Claims;
using System.Text;
using CKCQUIZZ.Server.Interfaces;
using CKCQUIZZ.Server.Models;
using CKCQUIZZ.Server.Services;
using CKCQUIZZ.Server.Viewmodels;
using CKCQUIZZ.Server.Viewmodels.Auth;
using CKCQUIZZ.Server.Viewmodels.Token;
using Microsoft.AspNetCore.Authentication;
using Microsoft.AspNetCore.Authentication.Google;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Identity;
using Microsoft.AspNetCore.Mvc;

namespace CKCQUIZZ.Server.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class AuthController(SignInManager<NguoiDung> _signInManager, IAuthService _authService, ITokenService _tokenService, LinkGenerator _linkGenerator) : ControllerBase
    {

        [HttpPost("signin")]
        public async Task<ActionResult<TokenResponse>> SignIn(SignInDTO request)
        {
            if (!ModelState.IsValid)
            {
                return BadRequest(ModelState);
            }
            try
            {
                var token = await _authService.SignInAsync(request);
                if (token is null)
                {
                    return BadRequest("Email hoặc mật khẩu không hợp lệ");
                }
                _tokenService.SetTokenInsideCookie(token, HttpContext);
                return Ok(token);

            }
            catch (Exception)
            {
                return StatusCode(500, "Đã xảy ra lỗi khi đăng nhập. Vui lòng thử lại sau.");
            }

        }
        [HttpPost("forgotpassword")]
        [AllowAnonymous]
        public async Task<IActionResult> ForgotPassword(ForgotPasswordDTO request)
        {
            if (!ModelState.IsValid)
            {
                return BadRequest(ModelState);
            }

            try
            {
                var email = await _authService.ForgotPasswordAsync(request);
                if (email is null)
                    return Unauthorized("Email không tồn tại");

                return Ok(new { Email = email });
            }
            catch (Exception)
            {
                return StatusCode(500, "Đã có lỗi xảy ra khi gửi email. Vui lòng thử lại sau.");
            }
        }
        [HttpPost("verifyotp")]
        [AllowAnonymous]
        public async Task<IActionResult> VerifyOtp(VerifyOtpDTO request)
        {
            if (!ModelState.IsValid)
            {
                return BadRequest(ModelState);
            }

            var (status, token, email) = await _authService.VerifyOtpAsync(request);

            return status switch
            {
                VerifyOtpStatus.Success => Ok(new
                {
                    Message = "Xác thực OTP thành công.",
                    Email = email,
                    PasswordResetToken = token
                }),

                VerifyOtpStatus.EmailNotFound => BadRequest(new { Message = "Không tìm thấy email hợp lệ." }),

                VerifyOtpStatus.InvalidOtp => BadRequest(new { Message = "Mã OTP không hợp lệ hoặc đã hết hạn." }),

                _ => StatusCode(500, new { Message = "Lỗi không xác định." })
            };
        }
        [HttpPost("resetpassword")]
        [AllowAnonymous]
        public async Task<IActionResult> ResetPassword(ResetPasswordDTO request)
        {
            if (!ModelState.IsValid)
            {
                return BadRequest(ModelState);
            }

            var (isSuccess, message) = await _authService.ResetPasswordAsync(request);

            if (isSuccess)
            {
                return Ok(new { Message = message });
            }
            else
            {
                return BadRequest(new { Message = message });
            }
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
        [HttpGet("google")]
        public IActionResult Google([FromQuery] string returnUrl)
        {
            var properties = _signInManager.ConfigureExternalAuthenticationProperties("Google", _linkGenerator.GetPathByName(HttpContext, "GoogleLoginCallback") + $"?returnUrl={returnUrl}");
            return Challenge(properties, ["Google"]);
        }
        [HttpGet("google-callback", Name = "GoogleLoginCallback")]
        public async Task<IActionResult> GoogleCallBack([FromQuery] string returnUrl)
        {
            var result = await HttpContext.AuthenticateAsync(GoogleDefaults.AuthenticationScheme);
            if (!result.Succeeded)
            {
                return Unauthorized("Xac thuc google khong thanh cong or khong tim thay principal");
            }
            await _authService.LoginWithGoogleAsync(result.Principal, this.HttpContext);
            if (!string.IsNullOrEmpty(returnUrl) && Url.IsLocalUrl(returnUrl))
            {
                return Redirect(returnUrl);
            }
            return Redirect(returnUrl);
        }
    }
}
