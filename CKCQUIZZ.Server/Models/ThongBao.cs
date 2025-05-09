using System;
using System.Collections.Generic;

namespace CKCQUIZZ.Server.Models;

public partial class ThongBao
{
    public int Matb { get; set; }

    public int? Malop { get; set; }

    public string? Manguoidung { get; set; }

    public string? Noidung { get; set; }

    public DateTime? Thoigiantao { get; set; }

    public string Nguoitao { get; set; } = null!;

    public virtual Lop? MalopNavigation { get; set; }

    public virtual NguoiDung? ManguoidungNavigation { get; set; }
}
