namespace CKCQUIZZ.Server.Viewmodels.Lop
{
    public class MonHocWithNhomLopDTO
    {
        public int Mamonhoc { get; set; }
        public string Tenmonhoc { get; set; } = default!;
        public int? Namhoc { get; set; }
        public int? Hocky { get; set; }
        public List<NhomLopInMonHocDTO> NhomLop { get; set; } = [];
    }
}