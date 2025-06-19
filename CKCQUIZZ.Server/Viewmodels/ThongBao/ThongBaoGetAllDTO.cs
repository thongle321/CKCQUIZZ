using System;
using System.Collections.Generic;

namespace CKCQUIZZ.Server.Viewmodels.ThongBao
{
    public class ThongBaoGetAllDTO
    {
        public int Matb { get; set; }
        public string? Noidung { get; set; }
        public string? Tenmonhoc { get; set; }
        public int? Namhoc { get; set; }
        public int? Hocky { get; set; }
        public DateTime? Thoigiantao { get; set; }
        public List<string> Nhom { get; set; } = new List<string>(); 
    }
}