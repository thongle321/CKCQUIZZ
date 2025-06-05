using CKCQUIZZ.Server.Models;
using CKCQUIZZ.Server.Viewmodels.User;
using Microsoft.AspNetCore.Identity;

namespace CKCQUIZZ.Server.Mappers
{
    public static class NguoiDungMappers
    {
        public static async Task<GetUserInfoDTO> ToNguoiDungDto(this NguoiDung nguoiDungModel, UserManager<NguoiDung> userManager)
        {
            var roles = await userManager.GetRolesAsync(nguoiDungModel);

            return new GetUserInfoDTO
            {
                MSSV = nguoiDungModel.Id,
                UserName = nguoiDungModel.UserName,
                Email = nguoiDungModel.Email,
                FullName = nguoiDungModel.Hoten,
                Dob = nguoiDungModel.Ngaysinh,
                PhoneNumber = nguoiDungModel.PhoneNumber,
                Status = nguoiDungModel.Trangthai,
                CurrentRole = roles.FirstOrDefault()
            };
        }

    }
}
