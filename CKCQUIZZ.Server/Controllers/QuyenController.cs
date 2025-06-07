using Microsoft.AspNetCore.Mvc;
using CKCQUIZZ.Server.Constants;
using Microsoft.Data.SqlClient;
using System.Data;
using System.Linq;
using System.Threading.Tasks;
using CKCQUIZZ.Server.Viewmodels.Permission;
using CKCQUIZZ.Server.Authorization;
using Dapper;

namespace CKCQUIZZ.Server.Controllers
{
    public class QuyenController(IConfiguration _configuration) : BaseController
    {
        [HttpGet]
        [ClaimRequirement(MaPhuongThuc.PHANQUYEN, MaHanhDong.VIEW)]
        public async Task<IActionResult> GetCommandViews()
        {
            using SqlConnection conn = new(_configuration.GetConnectionString("DefaultConnection"));
            if (conn.State == ConnectionState.Closed)
            {
                await conn.OpenAsync();
            }

            var sql = @"SELECT f.Id,
	                       f.Name,
	                       f.ParentId,
	                       sum(case when sa.Id = 'CREATE' then 1 else 0 end) as HasCreate,
	                       sum(case when sa.Id = 'UPDATE' then 1 else 0 end) as HasUpdate,
	                       sum(case when sa.Id = 'DELETE' then 1 else 0 end) as HasDelete,
	                       sum(case when sa.Id = 'VIEW' then 1 else 0 end) as HasView,
	                       sum(case when sa.Id = 'APPROVE' then 1 else 0 end) as HasApprove
                        from Functions f join CommandInFunctions cif on f.Id = cif.FunctionId
		                    left join Commands sa on cif.CommandId = sa.Id
                        GROUP BY f.Id,f.Name, f.ParentId
                        order BY f.ParentId";

            var result = await conn.QueryAsync<PermissionScreenDTO>(sql, null, null, 120, CommandType.Text);
            return Ok(result.ToList());
        }
    }
}