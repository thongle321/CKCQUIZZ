using CKCQUIZZ.Server.Interfaces;
using Microsoft.AspNetCore.Authentication;
using System.Security.Claims;

namespace CKCQUIZZ.Server.Authorization
{
    public class Claims(IPermissionService _permissionService) : IClaimsTransformation
    {

        public async Task<ClaimsPrincipal> TransformAsync(ClaimsPrincipal principal)
        {
            var userId = principal.FindFirstValue(ClaimTypes.NameIdentifier);
            if (string.IsNullOrEmpty(userId))
            {
                return principal;
            }

            var permissions = await _permissionService.GetUserPermissionsAsync(userId);

            var claimsIdentity = new ClaimsIdentity();
            foreach (var permission in permissions)
            {
                claimsIdentity.AddClaim(new Claim("Permission", permission));
            }

            principal.AddIdentity(claimsIdentity);
            return principal;
        }
    }
}