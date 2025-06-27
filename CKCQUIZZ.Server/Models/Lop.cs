namespace CKCQUIZZ.Server.Models;

public partial class Lop
{
    public int Malop { get; set; }

    public string Tenlop { get; set; } = null!;

    public string? Mamoi { get; set; }

    public int? Siso { get; set; }

    public string? Ghichu { get; set; }

    public int? Namhoc { get; set; }

    public int? Hocky { get; set; }

    public bool? Trangthai { get; set; }

    public bool? Hienthi { get; set; }

    public string Giangvien { get; set; } = null!;

    public virtual ICollection<ChiTietLop> ChiTietLops { get; set; } = [];

    public virtual NguoiDung GiangvienNavigation { get; set; } = null!;

    public virtual ICollection<DeThi> Mades { get; set; } = [];

    public virtual ICollection<ThongBao> Matbs { get; set; } = [];

    public virtual ICollection<DanhSachLop> DanhSachLops { get; set; } = [];

}
