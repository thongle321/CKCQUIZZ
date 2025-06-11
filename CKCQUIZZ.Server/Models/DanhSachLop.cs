namespace CKCQUIZZ.Server.Models;

public partial class DanhSachLop
{
    public int Malop { get; set; }

    public int Mamonhoc { get; set; }

    public virtual Lop MalopNavigation  { get; set; } = null!;
    
    public virtual MonHoc MamonhocNavigation  { get; set; } = null!;
}
