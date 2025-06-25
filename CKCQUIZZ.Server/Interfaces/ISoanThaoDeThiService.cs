using CKCQUIZZ.Server.Viewmodels.SoanThao;
using System.Threading.Tasks;

namespace CKCQUIZZ.Server.Interfaces
{
    public interface ISoanThaoDeThiService
    {
        Task<List<CauHoiSoanThaoViewModel>> GetCauHoiCuaDeThiAsync(int maDe);
        Task<bool> LuuThayDoiCauHoiAsync(int maDe, List<CauHoiSoanThaoViewModel> cauHoisFromClient, string userId);
    }
}