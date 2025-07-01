namespace CKCQUIZZ.Server.Viewmodels.DeThi
{
    public class ExamForClassDto
    {
        public int Made { get; set; }
        public string? Tende { get; set; }
        public string? TenMonHoc { get; set; }
        public int TongSoCau { get; set; }
        public int? Thoigianthi { get; set; }
        public DateTime? Thoigiantbatdau { get; set; }
        public DateTime? Thoigianketthuc { get; set; }

        public string TrangthaiThi { get; set; } = default!;
        public int? KetQuaId { get; set; }
    }
}