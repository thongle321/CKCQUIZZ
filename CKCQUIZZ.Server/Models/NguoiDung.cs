using Microsoft.AspNetCore.Identity;
using System;
using System.Collections.Generic;

namespace CKCQUIZZ.Server.Models;

public partial class NguoiDung : IdentityUser
{

    public string Hoten { get; set; } = null!;

    public bool? Gioitinh { get; set; }

    public DateTime? Ngaysinh { get; set; }

    public string? Avatar { get; set; }

    public DateTime Ngaythamgia { get; set; }

    public bool? Trangthai { get; set; }

    public int? Manhomquyen { get; set; }

    public virtual ICollection<CauHoi> CauHois { get; set; } = new List<CauHoi>();

    public virtual ICollection<ChiTietLop> ChiTietLops { get; set; } = new List<ChiTietLop>();

    public virtual ICollection<DeThi> DeThis { get; set; } = new List<DeThi>();

    public virtual ICollection<KetQua> KetQuas { get; set; } = new List<KetQua>();

    public virtual ICollection<Lop> Lops { get; set; } = new List<Lop>();

    public virtual NhomQuyen? ManhomquyenNavigation { get; set; }

    public virtual ICollection<ThongBao> ThongBaos { get; set; } = new List<ThongBao>();
}
