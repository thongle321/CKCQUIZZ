using CKCQUIZZ.Server.Models;
using CKCQUIZZ.Server.Viewmodels.Lop;
using System.Linq;

namespace CKCQUIZZ.Server.Mappers
{
    public static class LopMappers
    {
        public static LopDTO ToLopDto(this Lop lopModel)
        {
            return new LopDTO
            {
                Malop = lopModel.Malop,
                Tenlop = lopModel.Tenlop,
                Mamoi = lopModel.Mamoi,
                Siso = lopModel.ChiTietLops?.Count() ?? 0,
                Ghichu = lopModel.Ghichu,
                Namhoc = lopModel.Namhoc,
                Hocky = lopModel.Hocky,
                Trangthai = lopModel.Trangthai,
                Hienthi = lopModel.Hienthi,
                Giangvien = lopModel.Giangvien,
                Tengiangvien = lopModel.GiangvienNavigation?.Hoten,

                MonHocs = GetMonHocList(lopModel.DanhSachLops)
            };
        }


        public static Lop ToLopFromCreateDto(this CreateLopRequestDTO lopDto)
        {
            return new Lop
            {
                Tenlop = lopDto.Tenlop,
                Ghichu = lopDto.Ghichu,
                Namhoc = lopDto.Namhoc,
                Hocky = lopDto.Hocky,
                Trangthai = lopDto.Trangthai,
                Hienthi = lopDto.Hienthi,
            };

        }

        private static List<string> GetMonHocList(ICollection<DanhSachLop> danhSachLops)
        {
            if (danhSachLops is null || !danhSachLops.Any())
            {
                return new List<string>();
            }

            return danhSachLops.Where(dsl => dsl.MamonhocNavigation != null)
                                .Select(dsl => $"{dsl.Mamonhoc} - {dsl.MamonhocNavigation.Tenmonhoc}")
                                .ToList();
        }
    }

}
