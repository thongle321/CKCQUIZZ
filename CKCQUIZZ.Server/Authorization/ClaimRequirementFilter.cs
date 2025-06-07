using CKCQUIZZ.Server.Constants;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.Filters;
using System.Text.Json;

namespace CKCQUIZZ.Server.Authorization
{
    public class ClaimRequirementFilter(MaPhuongThuc _maPhuongThuc, MaHanhDong _maHanhDong) : IAuthorizationFilter
    {
        public void OnAuthorization(AuthorizationFilterContext context)
        {
            var quyenClaim = context.HttpContext.User.Claims
                .SingleOrDefault(c => c.Type == SystemConstants.Claims.Quyen);
            if (quyenClaim != null)
            {
                var quyen = JsonSerializer.Deserialize<List<string>>(quyenClaim.Value); if (!quyen!.Contains(_maPhuongThuc + "_" + _maHanhDong))
                {
                    context.Result = new ForbidResult();
                }
            }
            else
            {
                context.Result = new ForbidResult();
            }
        }
    }
}