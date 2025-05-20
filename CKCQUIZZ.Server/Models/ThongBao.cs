using System;
using System.Collections.Generic;

namespace CKCQUIZZ.Server.Models;

public partial class ThongBao
{
    public int Matb { get; set; }

    public string? Noidung { get; set; }

    public DateTime? Thoigiantao { get; set; }

    public string Nguoitao { get; set; } = null!;

    public virtual NguoiDung NguoitaoNavigation { get; set; } = null!;

    public virtual ICollection<Lop> Malops { get; set; } = new List<Lop>();
}
