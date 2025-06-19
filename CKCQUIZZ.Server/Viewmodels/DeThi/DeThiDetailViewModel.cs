namespace CKCQUIZZ.Server.Viewmodels.DeThi
{
    public class DeThiDetailViewModel
    {
        public int Made { get; set; }
        public string Tende { get; set; }
        public int Thoigianthi { get; set; }
        public DateTime? Thoigiantbatdau { get; set; }
        public DateTime? Thoigianketthuc { get; set; }
        public bool Hienthibailam { get; set; }
        public bool Xemdiemthi { get; set; }
        public bool Xemdapan { get; set; }
        public bool Troncauhoi { get; set; }
        public int Loaide { get; set; }
        public int Socaude { get; set; }
        public int Socautb { get; set; }
        public int Socaukho { get; set; }
        public List<int> Malops { get; set; } = new List<int>();
        public List<int> Machuongs { get; set; } = new List<int>();
    }
}
