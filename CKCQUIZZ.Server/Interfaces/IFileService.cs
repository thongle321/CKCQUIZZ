using CKCQUIZZ.Server.Viewmodels.CauHoi;
using Microsoft.AspNetCore.Http;
using System.Threading.Tasks;

namespace CKCQUIZZ.Server.Interfaces
{
    public interface IFileService
    {
        Task<string> UploadImageAsync(IFormFile file, string subfolder);
        Task<KetQuaImportViewModel> ImportFromZipAsync(IFormFile file, int maMonHoc, int maChuong, int doKho, string userId);
    }
}