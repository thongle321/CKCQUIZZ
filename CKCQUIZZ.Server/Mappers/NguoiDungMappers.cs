using CKCQUIZZ.Server.Models;
using CKCQUIZZ.Server.Viewmodels.NguoiDung;
using Microsoft.AspNetCore.Identity;

namespace CKCQUIZZ.Server.Mappers
{
    public static class NguoiDungMappers
    {
        public static async Task<GetNguoiDungDTO> ToNguoiDungDto(this NguoiDung nguoiDungModel, UserManager<NguoiDung> userManager)
        {
            var roles = await userManager.GetRolesAsync(nguoiDungModel);

            return new GetNguoiDungDTO
            {
                MSSV = nguoiDungModel.Id,
                UserName = nguoiDungModel.UserName!,
                Email = nguoiDungModel.Email!,
                Hoten = nguoiDungModel.Hoten,
                Ngaysinh = nguoiDungModel.Ngaysinh,
                PhoneNumber = nguoiDungModel.PhoneNumber!,
                Trangthai = nguoiDungModel.Trangthai,
                CurrentRole = roles.FirstOrDefault()
            };
        }
        public static Task<GetNguoiDungDTO> ToSinhVienDto(this NguoiDung nguoiDungModel)
        {
            return Task.FromResult(new GetNguoiDungDTO
            {
                MSSV = nguoiDungModel.Id,
                UserName = nguoiDungModel.UserName!,
                Email = nguoiDungModel.Email!,
                Hoten = nguoiDungModel.Hoten,
                Gioitinh = nguoiDungModel.Gioitinh,
                Ngaysinh = nguoiDungModel.Ngaysinh,
                PhoneNumber = nguoiDungModel.PhoneNumber!,
            });
        }

    }
}
