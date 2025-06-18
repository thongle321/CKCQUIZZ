using System;
using System.Collections.Generic;

namespace CKCQUIZZ.Server.Models;

public partial class DeThi
{
    public int Made { get; set; }

    public int? Monthi { get; set; }

    public string? Nguoitao { get; set; }

    public string? Tende { get; set; }

    public DateTime? Thoigiantao { get; set; }

    public int? Thoigianthi { get; set; }

    public DateTime? Thoigiantbatdau { get; set; }

    public DateTime? Thoigianketthuc { get; set; }

    public bool? Hienthibailam { get; set; }

    public bool? Xemdiemthi { get; set; }

    public bool? Xemdapan { get; set; }

    public bool? Troncauhoi { get; set; }

    public int? Loaide { get; set; }

    public int? Socaude { get; set; }

    public int? Socautb { get; set; }

    public int? Socaukho { get; set; }

    public bool? Trangthai { get; set; }

    public virtual ICollection<ChiTietDeThi> ChiTietDeThis { get; set; } = new List<ChiTietDeThi>();

    public virtual ICollection<KetQua> KetQuas { get; set; } = new List<KetQua>();

    public virtual NguoiDung? NguoitaoNavigation { get; set; }

    public virtual ICollection<GiaoDeThi> GiaoDeThis { get; set; } = new List<GiaoDeThi>();
}
