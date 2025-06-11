// Path: Viewmodels/CauHoi/CauHoiDetailDto.cs
namespace CKCQUIZZ.Server.Viewmodels.CauHoi
{
    public class CauHoiDetailDto
    {
        public int Macauhoi { get; set; }
        public string Noidung { get; set; }
        public int Dokho { get; set; }
        public int Mamonhoc { get; set; }
        public int Machuong { get; set; }
        public string TenDoKho { get; set; }
        public string TenMonHoc { get; set; }
        public string TenChuong { get; set; }
        public bool? Daodapan { get; set; }
        public bool Trangthai { get; set; }
        public List<CauTraLoiDetailDto> CauTraLois { get; set; }
    }
    public class CauTraLoiDetailDto
    {
        public int Macautl { get; set; }
        public string Noidungtl { get; set; }
        public bool Dapan { get; set; }
    }
}