using System;
using System.Collections.Generic;

namespace CKCQUIZZ.Server.Models;

public partial class ChiTietKetQua
{
    public int Makq { get; set; }

    public int Macauhoi { get; set; }

    public double? Diemketqua { get; set; }

    public virtual ICollection<ChiTietTraLoiSinhVien> ChiTietTraLoiSinhViens { get; set; } = new List<ChiTietTraLoiSinhVien>();

    public virtual CauHoi MacauhoiNavigation { get; set; } = null!;

    public virtual KetQua MakqNavigation { get; set; } = null!;
}
