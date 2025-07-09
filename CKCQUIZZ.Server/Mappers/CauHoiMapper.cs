using CKCQUIZZ.Server.Models;
using CKCQUIZZ.Server.Viewmodels.CauHoi;

namespace CKCQUIZZ.Server.Mappers
{
    public static class CauHoiMapper
    {
        private static string MapDoKhoToString(int dokho) => dokho switch
        {
            1 => "Dễ",
            2 => "Trung bình",
            3 => "Khó",
            _ => "Không xác định"
        };

        public static CauHoiDto ToCauHoiDto(this CauHoi model)
        {
            return new CauHoiDto
            {
                Macauhoi = model.Macauhoi,
                Noidung = model.Noidung,
                TenMonHoc = model.MamonhocNavigation?.Tenmonhoc ?? "N/A",
                TenChuong = model.MachuongNavigation?.Tenchuong ?? "N/A",
                TenDoKho = MapDoKhoToString(model.Dokho),
                Trangthai = model.Trangthai,
                Loaicauhoi= model.Loaicauhoi,
                Hinhanhurl = model.Hinhanhurl,
                Daodapan =model.Daodapan??false,
                NguoiTao= model.Nguoitao
            };
        }

        public static CauHoiDetailDto ToCauHoiDetailDto(this CauHoi model)
        {
            return new CauHoiDetailDto
            {
                Macauhoi = model.Macauhoi,
                Noidung = model.Noidung,
                Dokho = model.Dokho,
                Mamonhoc = model.Mamonhoc,
                Machuong = model.Machuong,
                TenDoKho = MapDoKhoToString(model.Dokho),
                TenMonHoc = model.MamonhocNavigation?.Tenmonhoc ?? "N/A",
                TenChuong = model.MachuongNavigation?.Tenchuong ?? "N/A",
                Daodapan = model.Daodapan,
                Trangthai = model.Trangthai,
                Loaicauhoi = model.Loaicauhoi,
                Hinhanhurl= model.Hinhanhurl,
                CauTraLois = model.CauTraLois.Select(ctl => new CauTraLoiDetailDto
                {
                    Macautl = ctl.Macautl,
                    Noidungtl = ctl.Noidungtl,
                    Dapan = ctl.Dapan
                }).ToList()
            };
        }
    }
}