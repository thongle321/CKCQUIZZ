namespace CKCQUIZZ.Server.Viewmodels.CauHoi
{
    public class CauHoiImportData
    {
            public string NoiDung { get; set; }
            public int? DoKho { get; set; }
            public string LoaiCauHoi { get; set; }
            public string TenFileAnh { get; set; }
            public string NoiDungGoiY { get; set; }
            public List<CauTraLoiImportData> CacLuaChon { get; set; } = new List<CauTraLoiImportData>();
        
    }
}
