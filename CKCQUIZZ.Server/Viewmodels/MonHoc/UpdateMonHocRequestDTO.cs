namespace CKCQUIZZ.Server.Viewmodels.MonHoc
{
    public class UpdateMonHocRequestDTO
    {
        public string Tenmonhoc { get; set; } = null!;

        public int Sotinchi { get; set; }

        public int Sotietlythuyet { get; set; }

        public int Sotietthuchanh { get; set; }

        public bool Trangthai { get; set; } = true;
    }
}


