using System;
using System.Collections.Generic;

namespace CKCQUIZZ.Server.Models;

public partial class ChiTietDeThi
{
    public int Made { get; set; }

    public int Macauhoi { get; set; }

    public double Diemcauhoi { get; set; }

    public int? Thutu { get; set; }

    public virtual CauHoi MacauhoiNavigation { get; set; } = null!;

    public virtual DeThi MadeNavigation { get; set; } = null!;
}
