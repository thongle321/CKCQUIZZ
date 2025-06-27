using System;
using System.Collections.Generic;

namespace CKCQUIZZ.Server.Models;

public partial class ChiTietDeThiSinhVien
{
    public int MachitietDTSV { get; set; }

    public string Id { get; set; } = null!;

    public int Made { get; set; }

    public int Macauhoi { get; set; }

    public float? Diem { get; set; }

    public virtual NguoiDung IdNavigation { get; set; } = null!;
    public virtual DeThi MadeNavigation { get; set; } = null!;
    public virtual CauHoi MacauhoiNavigation { get; set; } = null!;
}