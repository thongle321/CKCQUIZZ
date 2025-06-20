using System;
using System.Collections.Generic;
using System.Text.Json.Serialization;
using Microsoft.AspNetCore.Identity;

namespace CKCQUIZZ.Server.Models;

public partial class NguoiDung : IdentityUser
{
    public string Hoten { get; set; } = null!;

    public bool? Gioitinh { get; set; }

    public DateTime? Ngaysinh { get; set; }

    public string? Avatar { get; set; }

    public DateTime Ngaythamgia { get; set; }

    public bool? Trangthai { get; set; }

    public string? RefreshToken { get; set; }

    public DateTime? RefreshTokenExpiryTime { get; set; }

    [JsonIgnore]
    public virtual ICollection<CauHoi> CauHois { get; set; } = new List<CauHoi>();

    [JsonIgnore]
    public virtual ICollection<ChiTietLop> ChiTietLops { get; set; } = new List<ChiTietLop>();

    [JsonIgnore]
    public virtual ICollection<DeThi> DeThis { get; set; } = new List<DeThi>();

    [JsonIgnore]
    public virtual ICollection<KetQua> KetQuas { get; set; } = new List<KetQua>();

    [JsonIgnore]
    public virtual ICollection<Lop> Lops { get; set; } = new List<Lop>();

    [JsonIgnore]
    public virtual ICollection<PhanCong> PhanCongs { get; set; } = new List<PhanCong>();
    
    [JsonIgnore]
    public virtual ICollection<ThongBao> ThongBaos { get; set; } = new List<ThongBao>();

    [JsonIgnore]
    public virtual ICollection<Chuong> Chuongs { get; set; } = new List<Chuong>();
}
