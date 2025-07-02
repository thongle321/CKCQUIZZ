namespace CKCQUIZZ.Server.Viewmodels.CauHoi
{
    public class UpdateCauHoiRequestDto
    {
        
        public string Noidung { get; set; } = default!;
        public int Dokho { get; set; }
        public int MaMonHoc { get; set; }
        public int Machuong { get; set; }
        public bool? Daodapan { get; set; }
        public bool Trangthai { get; set; }
        public string Loaicauhoi { get; set; } = default!;
        public string? Hinhanhurl { get; set; }
        public List<UpdateCauTraLoiDto> CauTraLois { get; set; } = [];

    }
}
