using System;
using System.Collections.Generic;

namespace CKCQUIZZ.Server.Models;

public partial class Chuong
{
    public int Machuong { get; set; }

    public string Tenchuong { get; set; } = null!;

    public int Mamonhoc { get; set; }

    public bool? Trangthai { get; set; }

    public virtual ICollection<CauHoi> CauHois { get; set; } = new List<CauHoi>();

    public virtual MonHoc MamonhocNavigation { get; set; } = null!;
}
