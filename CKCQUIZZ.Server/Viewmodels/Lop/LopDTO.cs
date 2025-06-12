using CKCQUIZZ.Server.Models;

namespace CKCQUIZZ.Server.Viewmodels.Lop
{
    public class LopDTO
    {
        public int Malop { get; set; }
        public string Tenlop { get; set; } = default!;
        public string? Mamoi { get; set; } // Thêm mã mời vào DTO
        public int? Siso { get; set; }
        public string? Ghichu { get; set; }
        public int? Namhoc { get; set; }
        public int? Hocky { get; set; }
        public bool? Trangthai { get; set; }
        public bool? Hienthi { get; set; }
        public List<string> MonHocs { get; set; } = [];
    }
}


