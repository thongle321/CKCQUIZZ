using System.Security.Claims;
using Microsoft.AspNetCore.Authorization;
using CKCQUIZZ.Server.Authorization;

namespace CKCQUIZZ.Server.Authorization
{
    public class PermissionAuthorizationHandler : AuthorizationHandler<PermissionRequirement>
    {
        protected override Task HandleRequirementAsync(AuthorizationHandlerContext context, PermissionRequirement requirement)
        {
            // Expected format for requirement.Permission: "Module.Action" (e.g., "ThongBao.View")
            // Actual claim format from service: "Permission.module.action" (e.g., "Permission.thongbao.view")

            // Find a claim that matches the requirement, handling the "Permission." prefix and case-insensitivity
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