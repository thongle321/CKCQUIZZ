using System;
using System.Collections.Generic;

namespace CKCQUIZZ.Server.Models;

public partial class DanhMucChucNang
{
    public string Chucnang { get; set; } = null!;

    public string? Tenchucnang { get; set; }

    public virtual ICollection<ChiTietQuyen> ChiTietQuyens { get; set; } = new List<ChiTietQuyen>();
}
