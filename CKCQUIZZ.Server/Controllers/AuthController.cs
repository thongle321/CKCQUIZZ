using System.IdentityModel.Tokens.Jwt;
using System.Security.Claims;
using System.Text;
using CKCQUIZZ.Server.Interfaces;
using CKCQUIZZ.Server.Models;
using CKCQUIZZ.Server.Services;
using CKCQUIZZ.Server.Viewmodels;
using CKCQUIZZ.Server.Viewmodels.Auth;
using CKCQUIZZ.Server.Viewmodels.Token;
using FluentValidation;
using Microsoft.AspNetCore.Authentication;
using Microsoft.AspNetCore.Authentication.Google;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Identity;
using Microsoft.AspNetCore.Mvc;

namespace CKCQUIZZ.Server.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class AuthController(SignInManager<NguoiDung> _signInManager, UserManager<NguoiDung> _userManager, IAuthService _authService, ITokenService _tokenService, LinkGenerator _linkGenerator) : ControllerBase
    {

        [HttpPost("signin")]
        public async Task<ActionResult<TokenResponse>> SignIn(SignInDTO request, IValidator<SignInDTO> _validator)
        {

            var validationResult = await _validator.ValidateAsync(request);
            if (!validationResult.IsValid)
            {
                var problemDetails = new HttpValidationProblemDetails(validationResult.ToDictionary())
                {
                    Status = StatusCodes.Status400BadRequest,
                    Title = "Lỗi xác thực dữ liệu",
                    Instance = HttpContext.Request.Path
                };
                return BadRequest(problemDetails);
            }
            var user = await _userManager.FindByEmailAsync(request.Email);
            if (user is null || !await _userManager.CheckPasswordAsync(user, request.Password))
            {
                return BadRequest("Email hoặc mật khẩu không hợp lệ.");
            }

            var roles = await _userManager.GetRolesAsync(user);

            if (roles is null || !roles.Any())
            {
                return StatusCode(StatusCodes.Status403Forbidden, "Tài khoản chưa được gán vai trò.");
            }
            try
            {
                var token = await _authService.SignInAsync(request);
                if (token is null)
                {
                    return StatusCode(StatusCodes.Status500InternalServerError, "Không thể tạo token xác thực.");
                }
                _tokenService.SetTokenInsideCookie(token, HttpContext);
                return Ok(
                    new
                    {
                        user.Email,
                        Roles = roles.ToList()
                    }
                );

            }
            catch (Exception)
            {
                return StatusCode(500, "Đã xảy ra lỗi khi đăng nhập. Vui lòng thử lại sau.");
            }

        }
        [HttpPost("forgotpassword")]
        [AllowAnonymous]
        public async Task<IActionResult> ForgotPassword([FromBody] ForgotPasswordDTO request)
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
        public async Task<IActionResult> VerifyOtp([FromBody] VerifyOtpDTO request)
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
        public async Task<IActionResult> ResetPassword([FromBody] ResetPasswordDTO request)
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

        [Authorize]
        [HttpPost("logout")]
        public IActionResult LogOut()
        {
            _tokenService.ClearTokenFromCookie(HttpContext);

            return Ok(new { message = "Đăng xuất thành công" });
        }
    }
}
