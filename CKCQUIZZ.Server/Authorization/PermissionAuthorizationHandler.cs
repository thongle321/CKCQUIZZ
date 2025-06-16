using System.Security.Claims;
using Microsoft.AspNetCore.Authorization;
using CKCQUIZZ.Server.Authorization;

namespace CKCQUIZZ.Server.Authorization
{
    public class PermissionAuthorizationHandler : AuthorizationHandler<PermissionRequirement>
    {
        protected override Task HandleRequirementAsync(AuthorizationHandlerContext context, PermissionRequirement requirement)
        {
            if (context.User.HasClaim(c => c.Type == "Permission" && c.Value == requirement.Permission))
            {
                context.Succeed(requirement);
            }
            return Task.CompletedTask;
        }
    }
}