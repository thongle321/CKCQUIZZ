using CKCQUIZZ.Server.Viewmodels.SoanThao;
using System.Collections.Generic;
using System.Threading.Tasks;

namespace CKCQUIZZ.Server.Interfaces
{
    public interface ISoanThaoDeThiService
    {
        Task<IEnumerable<CauHoiSoanThaoViewModel>> GetCauHoiCuaDeThiAsync(int deThiId);
        Task<int> AddCauHoiVaoDeThiAsync(int deThiId, DapAnSoanThaoViewModel request);
        Task<bool> RemoveCauHoiFromDeThiAsync(int deThiId, int cauHoiId);
        Task<bool> RemoveMultipleCauHoisFromDeThiAsync(int deThiId, List<int> cauHoiIds);
    }
}