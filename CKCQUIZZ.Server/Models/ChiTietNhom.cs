using System;
using System.Collections.Generic;

namespace CKCQUIZZ.Server.Models;

public partial class ChiTietNhom
{
    public int Manhom { get; set; }

    public string Manguoidung { get; set; } = null!;

    public bool? Hienthi { get; set; }

    public virtual NguoiDung ManguoidungNavigation { get; set; } = null!;

    public virtual Nhom ManhomNavigation { get; set; } = null!;
}
