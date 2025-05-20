using System;
using System.Collections.Generic;

namespace CKCQUIZZ.Server.Models;

public partial class MonHoc
{
    public int Mamonhoc { get; set; }

    public string Tenmonhoc { get; set; } = null!;

    public int Sotinchi { get; set; }

    public int Sotietlythuyet { get; set; }

    public int Sotietthuchanh { get; set; }

    public bool? Trangthai { get; set; }

    public virtual ICollection<CauHoi> CauHois { get; set; } = new List<CauHoi>();

    public virtual ICollection<Chuong> Chuongs { get; set; } = new List<Chuong>();

    public virtual ICollection<Lop> Lops { get; set; } = new List<Lop>();
}
