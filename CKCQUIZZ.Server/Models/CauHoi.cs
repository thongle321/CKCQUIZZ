using System;
using System.Collections.Generic;

namespace CKCQUIZZ.Server.Models;

public partial class CauHoi
{
    public int Macauhoi { get; set; }

    public string Noidung { get; set; } = null!;

    public int Dokho { get; set; }

    public int Mamonhoc { get; set; }

    public int Machuong { get; set; }

    public string? Nguoitao { get; set; }

    public bool? Daodapan { get; set; }

    public bool Trangthai { get; set; }

    public virtual ICollection<CauTraLoi> CauTraLois { get; set; } = new List<CauTraLoi>();

    public virtual ICollection<ChiTietDeThi> ChiTietDeThis { get; set; } = new List<ChiTietDeThi>();

    public virtual ICollection<ChiTietKetQua> ChiTietKetQuas { get; set; } = new List<ChiTietKetQua>();

    public virtual Chuong MachuongNavigation { get; set; } = null!;

    public virtual MonHoc MamonhocNavigation { get; set; } = null!;

    public virtual NguoiDung? NguoitaoNavigation { get; set; }
}
