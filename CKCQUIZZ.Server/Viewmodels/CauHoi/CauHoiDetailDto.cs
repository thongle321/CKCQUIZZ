// Path: Viewmodels/CauHoi/CauHoiDetailDto.cs
namespace CKCQUIZZ.Server.Viewmodels.CauHoi
{
    public class CauHoiDetailDto
    {
        public int Macauhoi { get; set; }
        public string Noidung { get; set; } = string.Empty;
        public int Dokho { get; set; }
        public int Mamonhoc { get; set; }
        public int Machuong { get; set; }
        public string TenDoKho { get; set; } = string.Empty;
        public string TenMonHoc { get; set; } = string.Empty;
        public string TenChuong { get; set; } = string.Empty;
        public bool? Daodapan { get; set; }
        public bool Trangthai { get; set; }
        public string Loaicauhoi { get; set; } = string.Empty;
        public string? Hinhanhurl { get; set; }
        public List<CauTraLoiDetailDto> CauTraLois { get; set; }
    }
    public class CauTraLoiDetailDto
    {
        public int Macautl { get; set; }
        public string Noidungtl { get; set; }
        public bool Dapan { get; set; }
    }
}