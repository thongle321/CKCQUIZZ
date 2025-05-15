using System;
using System.Collections.Generic;

namespace CKCQUIZZ.Server.Models;

public partial class NhomQuyen
{
    public int Manhomquyen { get; set; }

    public string Tennhomquyen { get; set; } = null!;

    public bool Trangthai { get; set; }

    public virtual ICollection<NguoiDung> NguoiDungs { get; set; } = new List<NguoiDung>();
}
