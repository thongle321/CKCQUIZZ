using System.IdentityModel.Tokens.Jwt;
using System.Security.Claims;
using System.Text;
using CKCQUIZZ.Server.Interfaces;
using CKCQUIZZ.Server.Models;
using Microsoft.AspNetCore.Identity;
using Microsoft.IdentityModel.Tokens;
using System.Linq;
using System.Security.Cryptography;
using CKCQUIZZ.Server.Viewmodels;
using CKCQUIZZ.Server.Viewmodels.Token;
using Microsoft.AspNetCore.Mvc;
using Org.BouncyCastle.Security;

namespace CKCQUIZZ.Server.Services
{
    public class TokenService : ITokenService
    {
        private readonly IConfiguration _configuration;
        private readonly SymmetricSecurityKey _symmetricSecurityKey;
        private readonly UserManager<NguoiDung> _userManager;
        private readonly CkcquizzContext _context;

        public TokenService(IConfiguration configuration, UserManager<NguoiDung> userManager, CkcquizzContext context)
        {
            _configuration = configuration;
            var signingKey = _configuration["JWT:SigningKey"] ?? throw new InvalidOperationException("JWT:SigningKey is not configured.");
            _symmetricSecurityKey = new SymmetricSecurityKey(Encoding.UTF8.GetBytes(signingKey));
            _userManager = userManager;
            _context = context;
        }
        public string CreateToken(NguoiDung user)
        {
            var userRoles = _userManager.GetRolesAsync(user).GetAwaiter().GetResult();
            var claims = new List<Claim>
            {
                new(JwtRegisteredClaimNames.Email, user.Email ?? default!),
                new(JwtRegisteredClaimNames.GivenName, user.UserName ?? default!),
            };
            foreach (var role in userRoles)
            {
                claims.Add(new Claim(ClaimTypes.Role, role));
            }
            var creds = new SigningCredentials(_symmetricSecurityKey, SecurityAlgorithms.HmacSha512Signature);

            var tokenDescriptor = new SecurityTokenDescriptor
            {
                Subject = new ClaimsIdentity(claims),
                Expires = DateTime.Now.AddDays(1),
                SigningCredentials = creds,
                Issuer = _configuration["JWT:Issuer"],
                Audience = _configuration["JWT:Audience"]
            };

            var tokenHandler = new JwtSecurityTokenHandler();

            var token = tokenHandler.CreateToken(tokenDescriptor);

            return tokenHandler.WriteToken(token);
        }

        public void SetTokenInsideCookie(TokenResponse tokenResponse, HttpContext context)
        {
            context.Response.Cookies.Append("accessToken", tokenResponse.AccessToken,
            new CookieOptions
            {
                Expires = DateTimeOffset.UtcNow.AddMinutes(5),
                HttpOnly = true,
                IsEssential = true,
                Secure = true,
                SameSite = SameSiteMode.None
            });
            context.Response.Cookies.Append("refreshToken", tokenResponse.RefreshToken,
            new CookieOptions
            {
                Expires = DateTimeOffset.UtcNow.AddDays(7),
                HttpOnly = true,
                IsEssential = true,
                Secure = true,
                SameSite = SameSiteMode.None
            });
        }

        public void ClearTokenFromCookie(HttpContext context)
        {
            var cookieOptions = new CookieOptions
            {
                HttpOnly = true,
                Secure = true,
                IsEssential = true,
                SameSite = SameSiteMode.None,
                Expires = DateTime.UtcNow.AddDays(-1)
            };

            context.Response.Cookies.Append("accessToken", "", cookieOptions);
            context.Response.Cookies.Append("refreshToken", "", cookieOptions);
        }

        public async Task<TokenResponse> CreateTokenResponse(NguoiDung? user)
        {
            if (user is null)
            {
                ArgumentNullException.ThrowIfNull(user);
            }
            return new TokenResponse
            {
                AccessToken = CreateToken(user),
                RefreshToken = await GenerateAndSaveRefreshTokenAsync(user),

            };
        }

        public async Task<TokenResponse?> RefreshTokensAsync(RefreshTokenRequest request)
        {
            var user = await ValidateRefreshTokenAsync(request.Id, request.RefreshToken);
            if (user is null)
            {
                return null;
            }
            return await CreateTokenResponse(user);
        }


        public async Task<NguoiDung?> ValidateRefreshTokenAsync(string Id, string refreshToken)
        {
            var user = await _context.NguoiDungs.FindAsync(Id);
            if (user is null || user.RefreshToken != refreshToken || user.RefreshTokenExpiryTime <= DateTime.Now)
            {
                return null;
            }
            return user;
        }
        public string GenerateRefreshToken()
        {
            var randomNumber = new byte[32];
            using var rng = RandomNumberGenerator.Create();
            rng.GetBytes(randomNumber);
            return Convert.ToBase64String(randomNumber);
        }
        public async Task<string> GenerateAndSaveRefreshTokenAsync(NguoiDung user)
        {
            var refreshToken = GenerateRefreshToken();
            user.RefreshToken = refreshToken;
            user.RefreshTokenExpiryTime = DateTime.Now.AddDays(7);
            await _context.SaveChangesAsync();
            return refreshToken;
        }
    }
}