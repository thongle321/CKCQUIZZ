namespace CKCQUIZZ.Server.Models
{
    public partial class PhanCong 
    {
        public int Mamonhoc { get; set; }

        public string Manguoidung { get; set; } = default!;

        public virtual MonHoc MamonhocNavigation { get; set; } = default!;
        
        public virtual NguoiDung ManguoidungNavigation { get; set; } = default!;

    }
}