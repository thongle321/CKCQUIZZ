using System.Collections.Generic;

namespace CKCQUIZZ.Server.Viewmodels.ThongBao
{
    public class ThongBaoDetailDTO
    {
        public int Matb { get; set; }
        public int Mamonhoc { get; set; }
        public string? Noidung { get; set; }
        public string? Tenmonhoc { get; set; }
        public int? Namhoc { get; set; }
        public int? Hocky { get; set; }
        public List<int> Nhom { get; set; } = [];
    }
}