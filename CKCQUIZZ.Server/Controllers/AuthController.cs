using System.IdentityModel.Tokens.Jwt;
using System.Security.Claims;
using System.Text;
using CKCQUIZZ.Server.Interfaces;
using CKCQUIZZ.Server.Models;
using CKCQUIZZ.Server.Viewmodels;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Identity;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Caching.Memory;
using Microsoft.IdentityModel.Tokens;

namespace CKCQUIZZ.Server.Controllers
{
    [ApiController]
    [Route("[controller]")]
    public class AuthController : ControllerBase
    {
        private readonly UserManager<NguoiDung> _userManager;
        private readonly IConfiguration _configuration;
        private readonly ITokenService _tokenService;
        private readonly SignInManager<NguoiDung> _signInManager;
        private readonly IEmailSender _emailSender;
        private readonly IMemoryCache _cache;
        private readonly Random _random = new Random();
        private const int OtpExpirationMinutes = 30;
        private const string OtpLength = "D6";

        public AuthController(UserManager<NguoiDung> userManager, SignInManager<NguoiDung> signInManager, IConfiguration configuration, ITokenService tokenService, IEmailSender emailSender, IMemoryCache memoryCache)
        {
            _userManager = userManager;
            _signInManager = signInManager;
            _configuration = configuration;
            _tokenService = tokenService;
            _emailSender = emailSender;
            _cache = memoryCache;
        }

        [HttpPost("signin")]
        public async Task<IActionResult> SignIn(SignInDTO request)
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

            return Ok(new NewUserDTO
            {
                Email = user.Email,
                Token = _tokenService.CreateToken(user)
            });
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

            if (user == null)
            {
                return Unauthorized("Email không đúng");
            }

            string otp = GenerateOtp(OtpLength);

            var cacheOptions = new MemoryCacheEntryOptions()
                .SetAbsoluteExpiration(TimeSpan.FromMinutes(OtpExpirationMinutes));

            _cache.Set(user.Id, otp, cacheOptions);

            var emailSubject = "Mã đặt lại mật khẩu của bạn";
            var emailMessage = $"<h2>Xin chào {user.Email},<br/><br/></h2>" +
                               $"<h2>Mã đặt lại mật khẩu của bạn là: <strong>{otp}</strong><br/><br/></h2>" +
                               $"<h2>Mã này sẽ hết hạn sau {OtpExpirationMinutes} phút.<br/><br/></h2>" +
                               $"<h2>Nếu bạn không yêu cầu đặt lại mật khẩu, vui lòng bỏ qua email này.</h2>";

            try
            {
                await _emailSender.SendEmailAsync(user.Email, emailSubject, emailMessage);
            }
            catch (Exception ex)
            {

            }
            return Ok(new NewUserDTO
            {
                Email = request.Email,
            });
        }
        private string GenerateOtp(string length)
        {
            string otpNumber = _random.Next(0, 1000000).ToString(length);
            return otpNumber;
        }
    }
}
