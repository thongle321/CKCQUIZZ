using System;
using System.Collections.Generic;

namespace CKCQUIZZ.Server.Models;

public partial class ChiTietLop
{
    public int Malop { get; set; }

    public string Manguoidung { get; set; } = null!;

    public bool? Trangthai { get; set; }

    public virtual Lop MalopNavigation { get; set; } = null!;

    public virtual NguoiDung ManguoidungNavigation { get; set; } = null!;
}
