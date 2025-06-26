using System;
using System.Collections.Generic;

namespace CKCQUIZZ.Server.Models;

public partial class ChiTietTraLoiSinhVien
{
    public int Matraloichitiet { get; set; }

    public int Makq { get; set; }

    public int Macauhoi { get; set; }

    public int Macautl { get; set; }

    public int Dapansv { get; set; }

    public DateTime? Thoigiantraloi { get; set; }

    public virtual ChiTietKetQua ChiTietKetQua { get; set; } = null!;

    public virtual CauTraLoi MacautlNavigation { get; set; } = null!;

    public virtual CauHoi MacauhoiNavigation { get; set; } = null!;

    public virtual KetQua MakqNavigation { get; set; } = null!;
}
