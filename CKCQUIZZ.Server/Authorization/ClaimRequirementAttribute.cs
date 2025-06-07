using CKCQUIZZ.Server.Constants;
using Microsoft.AspNetCore.Mvc;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace CKCQUIZZ.Server.Authorization
{
    public class ClaimRequirementAttribute : TypeFilterAttribute
    {
        public ClaimRequirementAttribute(MaPhuongThuc maPhuongThuc, MaHanhDong maHanhDong)
            : base(typeof(ClaimRequirementFilter))
        {
            Arguments = new object[] { maPhuongThuc, maHanhDong };
        }
    }
}