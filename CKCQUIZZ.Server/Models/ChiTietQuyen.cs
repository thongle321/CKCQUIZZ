using System;
using System.Collections.Generic;

namespace CKCQUIZZ.Server.Models;

public partial class ChiTietQuyen
{
    public int Manhomquyen { get; set; }

    public string Chucnang { get; set; } = null!;

    public string Hanhdong { get; set; } = null!;

    public virtual DanhMucChucNang ChucnangNavigation { get; set; } = null!;

    public virtual NhomQuyen ManhomquyenNavigation { get; set; } = null!;
}
