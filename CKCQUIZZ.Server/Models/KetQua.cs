using System;
using System.Collections.Generic;

namespace CKCQUIZZ.Server.Models;

public partial class KetQua
{
    public int Makq { get; set; }

    public int Made { get; set; }

    public string Manguoidung { get; set; } = null!;

    public double? Diemthi { get; set; }

    public DateTime? Thoigianvaothi { get; set; }

    public int? Thoigiansolambai { get; set; }

    public int? Socaudung { get; set; }

    public int? Solanchuyentab { get; set; }

    public virtual ICollection<ChiTietKetQua> ChiTietKetQuas { get; set; } = new List<ChiTietKetQua>();

    public virtual DeThi MadeNavigation { get; set; } = null!;

    public virtual NguoiDung ManguoidungNavigation { get; set; } = null!;
}
