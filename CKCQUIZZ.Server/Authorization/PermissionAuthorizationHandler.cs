using System.Security.Claims;
using Microsoft.AspNetCore.Authorization;
using CKCQUIZZ.Server.Authorization;

namespace CKCQUIZZ.Server.Authorization
{
    public class PermissionAuthorizationHandler : AuthorizationHandler<PermissionRequirement>
    {
        protected override Task HandleRequirementAsync(AuthorizationHandlerContext context, PermissionRequirement requirement)
        {

            if (context.User.HasClaim(c =>
                c.Type == "Permission" &&
                c.Value.StartsWith("Permission.", StringComparison.OrdinalIgnoreCase) &&
                string.Equals(c.Value.Substring("Permission.".Length), requirement.Permission, StringComparison.OrdinalIgnoreCase)))
            {
                context.Succeed(requirement);
            }
            return Task.CompletedTask;
        }
    }
}