using System;

namespace CKCQUIZZ.Server.Viewmodels.ThongBao
{
    public class ThongBaoDTO
    {
        public int Matb { get; set; }
        public string? Nguoitao { get; set; }
        public string? Tennhom { get; set; }
        public string? Avatar { get; set; }
        public string? Hoten { get; set; }
        public string? Noidung { get; set; }
        public DateTime? Thoigiantao { get; set; }
        public int Manhom { get; set; }
        public int Mamonhoc { get; set; }
        public string? Tenmonhoc { get; set; }
    }
}