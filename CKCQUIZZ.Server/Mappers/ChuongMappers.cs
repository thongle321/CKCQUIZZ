// File: Mappers/ChuongMappers.cs
using CKCQUIZZ.Server.Models;
using CKCQUIZZ.Server.Viewmodels.Chuong;
namespace CKCQUIZZ.Server.Mappers
{
    public static class ChuongMappers
    {
        public static ChuongDTO ToChuongDto(this Chuong chuong)
        {
            return new ChuongDTO
            {
                Machuong = chuong.Machuong,
                Tenchuong = chuong.Tenchuong,
                Mamonhoc = chuong.Mamonhoc,
                Trangthai = chuong.Trangthai
            };
        }

        public static Chuong ToChuongFromCreateDto(this CreateChuongRequestDTO chuongDto)
        {
            return new Chuong
            {
                Tenchuong = chuongDto.Tenchuong,
                Mamonhoc = chuongDto.Mamonhoc,
                Trangthai = chuongDto.Trangthai
            };
        }
    }
}