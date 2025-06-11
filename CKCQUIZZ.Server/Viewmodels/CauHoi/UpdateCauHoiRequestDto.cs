namespace CKCQUIZZ.Server.Viewmodels.CauHoi
{
    public class UpdateCauHoiRequestDto
    {
        public string Noidung { get; set; }
        public int Dokho { get; set; }
        public int Machuong { get; set; }
        public bool? Daodapan { get; set; }
        public bool Trangthai { get; set; }
        public List<UpdateCauTraLoiDto> CauTraLois { get; set; }

    }
}
