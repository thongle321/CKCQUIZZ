using CKCQUIZZ.Server.Models;

namespace CKCQUIZZ.Server.Interfaces
{
    public interface ITokenService
    {
        string CreateToken(NguoiDung user);
    }
}