using CKCQUIZZ.Server.Models;
using CKCQUIZZ.Server.Viewmodels.Subject;

namespace CKCQUIZZ.Server.Mappers
{
    public static class MonHocMappers
    {
        public static MonHocDTO ToMonHocDto(this MonHoc monhocModel)
        {
            return new MonHocDTO
            {
                Mamonhoc = monhocModel.Mamonhoc,
                Tenmonhoc = monhocModel.Tenmonhoc,
                Sotinchi = monhocModel.Sotinchi,
                Sotietlythuyet = monhocModel.Sotietlythuyet,
                Sotietthuchanh = monhocModel.Sotietthuchanh,
                Trangthai = monhocModel.Trangthai
            };
        }

        public static MonHoc ToMonHocFromCreateDto(this CreateMonHocRequestDTO monHocDto)
        {
            return new MonHoc
            {
                Mamonhoc = monHocDto.Mamonhoc,
                Tenmonhoc = monHocDto.Tenmonhoc,
                Sotinchi = monHocDto.Sotinchi,
                Sotietlythuyet = monHocDto.Sotietlythuyet,
                Sotietthuchanh = monHocDto.Sotietthuchanh,
                Trangthai = monHocDto.Trangthai
            };
        }
    }
}