namespace CKCQUIZZ.Server.Viewmodels.CauHoi
{
    public class CauHoiImportData
    {
            public string NoiDung { get; set; } = default!;
            public int? DoKho { get; set; }
            public string LoaiCauHoi { get; set; } = default!;
            public string TenFileAnh { get; set; } = default!;
            public string NoiDungGoiY { get; set; } = default!;
            public List<CauTraLoiImportData> CacLuaChon { get; set; } = [];
        
    }
}
