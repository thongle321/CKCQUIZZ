using System.IdentityModel.Tokens.Jwt;
using System.Security.Claims;
using System.Text;
using CKCQUIZZ.Server.Interfaces;
using CKCQUIZZ.Server.Models;
using CKCQUIZZ.Server.Viewmodels;
using Microsoft.AspNetCore.Identity;
using Microsoft.AspNetCore.Mvc;
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

        public AuthController(UserManager<NguoiDung> userManager, SignInManager<NguoiDung> signInManager, IConfiguration configuration, ITokenService tokenService)
        {
            _userManager = userManager;
            _signInManager = signInManager;
            _configuration = configuration;
            _tokenService = tokenService;
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
            
            return Ok(new NewUserDTO {
                Email = user.Email,
                Token = _tokenService.CreateToken(user)
            });
        }

        // private string CreateToken(NguoiDung user)
        // {
        //     var claims = new List<Claim>
        //     {
        //         new Claim(ClaimTypes.Email, user.Email)
        //     };
        //     var key = new SymmetricSecurityKey(Encoding.UTF8.GetBytes(_configuration.GetValue<string>("AppSettings:Token")!));

        //     var creds = new SigningCredentials(key, SecurityAlgorithms.HmacSha512);

        //     var tokenDescriptor = new JwtSecurityToken(
        //         issuer: _configuration.GetValue<string>("AppSettings:Issuer"),
        //         audience: _configuration.GetValue<string>("AppSettings:Audience"),
        //         claims: claims,
        //         expires: DateTime.UtcNow.AddDays(1),
        //         signingCredentials: creds
        //     );

        //     return new JwtSecurityTokenHandler().WriteToken(tokenDescriptor);
        // }
    }
}
