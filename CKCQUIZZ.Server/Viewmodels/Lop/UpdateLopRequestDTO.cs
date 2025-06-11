namespace CKCQUIZZ.Server.Viewmodels.Lop
{
    public class UpdateLopRequestDTO
    {
        public string Tenlop { get; set; } = default!;
        public string? Ghichu { get; set; }
        public int? Namhoc { get; set; }
        public int? Hocky { get; set; }
        public bool? Trangthai { get; set; }
        public bool? Hienthi { get; set; }
        public int Mamonhoc { get; set; }

    }
}


