namespace CKCQUIZZ.Server.Viewmodels.DeThi
{
    public class DeThiViewModel
    {
        public int Made { get; set; }
        public string? Tende { get; set; }
        public string GiaoCho { get; set; } = default!;
        public int Monthi { get; set; }
        public DateTime? Thoigianbatdau { get; set; }
        public DateTime? Thoigianketthuc { get; set; }
        public bool Trangthai { get; set; }
        public bool Xemdiemthi { get; set; }
        public bool Hienthibailam { get; set; }
        public bool Xemdapan { get; set; }
        public bool Troncauhoi { get; set; }
        public string? NguoiTao { get; set; }

    }
   
}
