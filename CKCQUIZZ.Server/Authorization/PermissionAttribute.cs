using Microsoft.AspNetCore.Authorization;

namespace CKCQUIZZ.Server.Authorization
{
    public class PermissionAttribute : AuthorizeAttribute
    {
        public PermissionAttribute(string permission)
        {
            Policy = $"Permission.{permission}";
        }
    }
}