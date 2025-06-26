namespace CKCQUIZZ.Server.Viewmodels.CauHoi
{
    public class QueryCauHoiDto
    {
        public int? MaMonHoc { get; set; }
        public int? MaChuong { get; set; }
        public int? DoKho { get; set; }
        public string? Keyword { get; set; }
        public string? NguoiTao { get; set; } // Filter by creator
        public int PageNumber { get; set; } = 1;
        public int PageSize { get; set; } = 10;
    }
}
