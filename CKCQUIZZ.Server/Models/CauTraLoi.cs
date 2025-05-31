using System;
using System.Collections.Generic;

namespace CKCQUIZZ.Server.Models;

public partial class CauTraLoi
{
    public int Macautl { get; set; }

    public int Macauhoi { get; set; }

    public string Noidungtl { get; set; } = null!;

    public string? Cautltuluan { get; set; }

    public bool Cautl { get; set; }

    public virtual ICollection<ChiTietTraLoiSinhVien> ChiTietTraLoiSinhViens { get; set; } = new List<ChiTietTraLoiSinhVien>();

    public virtual CauHoi MacauhoiNavigation { get; set; } = null!;
}
