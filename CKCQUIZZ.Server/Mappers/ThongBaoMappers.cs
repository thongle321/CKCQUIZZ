using CKCQUIZZ.Server.Models;
using CKCQUIZZ.Server.Viewmodels.ThongBao;

namespace CKCQUIZZ.Server.Mappers
{
    public static class ThongBaoMappers
    {
        public static ThongBaoDTO ToThongBaoDto(this ThongBao thongBaoModel)
        {
            return new ThongBaoDTO
            {
                Matb = thongBaoModel.Matb,
                Noidung = thongBaoModel.Noidung,
                Thoigiantao = thongBaoModel.Thoigiantao,
                Nguoitao = thongBaoModel.Nguoitao,
            };
        }

        public static ThongBao ToThongBaoFromCreateDto(this CreateThongBaoRequestDTO thongBaoDTO)
        {
            return new ThongBao
            {
                Noidung = thongBaoDTO.Noidung,
                Thoigiantao = thongBaoDTO.Thoigiantao,
            };
        }
    }
}