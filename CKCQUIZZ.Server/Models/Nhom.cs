using System;
using System.Collections.Generic;

namespace CKCQUIZZ.Server.Models;

public partial class Nhom
{
    public int Manhom { get; set; }

    public string Tennhom { get; set; } = null!;

    public string? Mamoi { get; set; }

    public byte? Siso { get; set; }

    public string? Ghichu { get; set; }

    public int? Namhoc { get; set; }

    public int? Hocky { get; set; }

    public bool? Trangthai { get; set; }

    public bool? Hienthi { get; set; }

    public string Giangvien { get; set; } = null!;

    public int Mamonhoc { get; set; }

    public virtual ICollection<ChiTietNhom> ChiTietNhoms { get; set; } = new List<ChiTietNhom>();

    public virtual MonHoc MamonhocNavigation { get; set; } = null!;

    public virtual ICollection<ThongBao> ThongBaos { get; set; } = new List<ThongBao>();

    public virtual ICollection<DeThi> Mades { get; set; } = new List<DeThi>();
}
