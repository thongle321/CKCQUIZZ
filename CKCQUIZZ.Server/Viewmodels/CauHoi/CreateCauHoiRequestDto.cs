namespace CKCQUIZZ.Server.Viewmodels.CauHoi
{
    public class CreateCauHoiRequestDto
    {
        public string Noidung { get; set; }
        public int Dokho { get; set; }
        public int Mamonhoc { get; set; }
        public int Machuong { get; set; }
        public bool? Daodapan { get; set; }
        public List<CreateCauTraLoiDto> CauTraLois { get; set; }
    }
}
