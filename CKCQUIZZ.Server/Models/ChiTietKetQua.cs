using System;
using System.Collections.Generic;

namespace CKCQUIZZ.Server.Models;

public partial class ChiTietKetQua
{
    public int Makq { get; set; }

    public int Macauhoi { get; set; }

    public int? Dapanchon { get; set; }

    public virtual CauTraLoi? DapanchonNavigation { get; set; }

    public virtual CauHoi MacauhoiNavigation { get; set; } = null!;

    public virtual KetQua MakqNavigation { get; set; } = null!;
}
