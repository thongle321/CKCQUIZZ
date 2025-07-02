namespace CKCQUIZZ.Server.Viewmodels.DeThi
{
    public class DeThiCreateRequest
    {
        public string Tende { get; set; } = default!;
        public DateTime Thoigianbatdau { get; set; }
        public DateTime Thoigianketthuc { get; set; }
        public int Thoigianthi { get; set; }
        public int Monthi { get; set; }
        public List<int> Malops { get; set; } = [];
        public bool Xemdiemthi { get; set; }
        public bool Hienthibailam { get; set; }
        public bool Xemdapan { get; set; }
        public bool Troncauhoi { get; set; }
        public int Loaide { get; set; }
        public List<int> Machuongs { get; set; } = [];
        public int Socaude { get; set; }
        public int Socautb { get; set; }
        public int Socaukho { get; set; }
    }
}
