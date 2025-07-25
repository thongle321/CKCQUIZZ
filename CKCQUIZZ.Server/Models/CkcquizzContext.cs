﻿using System;
using System.Collections.Generic;
using Microsoft.AspNetCore.Identity;
using Microsoft.AspNetCore.Identity.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore;

namespace CKCQUIZZ.Server.Models;

public partial class CkcquizzContext : IdentityDbContext<NguoiDung, ApplicationRole, string>
{
    public CkcquizzContext()
    {
    }

    public CkcquizzContext(DbContextOptions<CkcquizzContext> options)
        : base(options)
    {
    }

    public virtual DbSet<CauHoi> CauHois { get; set; }

    public virtual DbSet<CauTraLoi> CauTraLois { get; set; }

    public virtual DbSet<ChiTietDeThi> ChiTietDeThis { get; set; }

    public virtual DbSet<ChiTietKetQua> ChiTietKetQuas { get; set; }

    public virtual DbSet<ChiTietLop> ChiTietLops { get; set; }

    public virtual DbSet<ChiTietTraLoiSinhVien> ChiTietTraLoiSinhViens { get; set; }

    public virtual DbSet<Chuong> Chuongs { get; set; }

    public virtual DbSet<DeThi> DeThis { get; set; }

    public virtual DbSet<KetQua> KetQuas { get; set; }

    public virtual DbSet<Lop> Lops { get; set; }

    public virtual DbSet<MonHoc> MonHocs { get; set; }

    public virtual DbSet<DanhSachLop> DanhSachLops { get; set; }

    public virtual DbSet<NguoiDung> NguoiDungs { get; set; }

    public virtual DbSet<ThongBao> ThongBaos { get; set; }

    public virtual DbSet<PhanCong> PhanCongs { get; set; }

    public virtual DbSet<DanhMucChucNang> DanhMucChucNangs { get; set; }

    public virtual DbSet<ChiTietQuyen> ChiTietQuyens { get; set; }

    public virtual DbSet<ChiTietDeThiSinhVien> ChiTietDeThiSinhViens { get; set; }


    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        base.OnModelCreating(modelBuilder);

        modelBuilder.Entity<ApplicationRole>().Property(x => x.Id).HasMaxLength(50).IsUnicode(false);
        modelBuilder.Entity<CauHoi>(entity =>
        {

            entity.HasKey(e => e.Macauhoi).HasName("PK__CauHoi__95E62F03B214AAA6");

            entity.ToTable("CauHoi");

            entity.Property(e => e.Macauhoi).HasColumnName("macauhoi");
            entity.Property(e => e.Daodapan).HasColumnName("daodapan");
            entity.Property(e => e.Dokho).HasColumnName("dokho");
            entity.Property(e => e.Machuong).HasColumnName("machuong");
            entity.Property(e => e.Mamonhoc).HasColumnName("mamonhoc");
            entity.Property(e => e.Nguoitao)
                .HasMaxLength(50)
                .HasColumnName("nguoitao");
            entity.Property(e => e.Noidung)
                .HasMaxLength(500)
                .HasColumnName("noidung");
            entity.Property(e => e.Loaicauhoi)
                .HasMaxLength(50)
                .HasColumnName("loaicauhoi");
            entity.Property(e => e.Hinhanhurl)
                .HasMaxLength(500)
                .HasColumnName("hinhanhurl");
            entity.Property(e => e.Trangthai)
                .HasDefaultValue(true)
                .HasColumnName("trangthai");

            entity.HasOne(d => d.MachuongNavigation).WithMany(p => p.CauHois)
                .HasForeignKey(d => d.Machuong)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("FK__CauHoi__machuong__7D439ABD");

            entity.HasOne(d => d.MamonhocNavigation).WithMany(p => p.CauHois)
                .HasForeignKey(d => d.Mamonhoc)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("FK__CauHoi__mamonhoc__7E37BEF6");

            entity.HasOne(d => d.NguoitaoNavigation).WithMany(p => p.CauHois)
                .HasForeignKey(d => d.Nguoitao)
                .HasConstraintName("FK_CauHoi_NguoiDung");
        });

        modelBuilder.Entity<CauTraLoi>(entity =>
        {
            entity.HasKey(e => e.Macautl).HasName("PK__CauTraLo__190C43E2D12394B7");

            entity.ToTable("CauTraLoi");

            entity.Property(e => e.Macautl).HasColumnName("macautl");

            entity.Property(e => e.Dapan).HasColumnName("dapan");

            entity.Property(e => e.Macauhoi).HasColumnName("macauhoi");
            entity.Property(e => e.Noidungtl)
                .HasMaxLength(500)
                .HasColumnName("noidungtl");

            entity.HasOne(d => d.MacauhoiNavigation).WithMany(p => p.CauTraLois)
                .HasForeignKey(d => d.Macauhoi)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("FK__CauTraLoi__macau__7F2BE32F");
        });

        modelBuilder.Entity<ChiTietDeThi>(entity =>
        {
            entity.HasKey(e => new { e.Made, e.Macauhoi }).HasName("PK__ChiTietD__537F82A8D7C214BF");

            entity.ToTable("ChiTietDeThi");

            entity.Property(e => e.Made).HasColumnName("made");
            entity.Property(e => e.Macauhoi).HasColumnName("macauhoi");
            entity.Property(e => e.Diemcauhoi).HasColumnName("diemcauhoi");
            entity.Property(e => e.Thutu).HasColumnName("thutu");

            entity.HasOne(d => d.MacauhoiNavigation).WithMany(p => p.ChiTietDeThis)
                .HasForeignKey(d => d.Macauhoi)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("FK__ChiTietDe__macau__00200768");

            entity.HasOne(d => d.MadeNavigation).WithMany(p => p.ChiTietDeThis)
                .HasForeignKey(d => d.Made)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("FK__ChiTietDeT__made__01142BA1");
        });

        modelBuilder.Entity<ChiTietKetQua>(entity =>
        {
            entity.HasKey(e => new { e.Makq, e.Macauhoi }).HasName("PK__ChiTietK__537FD9B3DDAB731B");

            entity.ToTable("ChiTietKetQua");

            entity.Property(e => e.Makq).HasColumnName("makq");
            entity.Property(e => e.Macauhoi).HasColumnName("macauhoi");
            entity.Property(e => e.Diemketqua).HasColumnName("diemketqua");

            entity.HasOne(d => d.MacauhoiNavigation).WithMany(p => p.ChiTietKetQuas)
                .HasForeignKey(d => d.Macauhoi)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("FK__ChiTietKe__macau__02084FDA");

            entity.HasOne(d => d.MakqNavigation).WithMany(p => p.ChiTietKetQuas)
                .HasPrincipalKey(p => p.Makq)
                .HasForeignKey(d => d.Makq)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("FK__ChiTietKet__makq__03F0984C");
        });

        modelBuilder.Entity<ChiTietLop>(entity =>
        {
            entity.HasKey(e => new { e.Malop, e.Manguoidung }).HasName("PK__ChiTietN__494FA06D1DCEF6FB");

            entity.ToTable("ChiTietLop");

            entity.Property(e => e.Malop).HasColumnName("malop");
            entity.Property(e => e.Manguoidung)
                .HasMaxLength(50)
                .HasDefaultValue("0")
                .HasColumnName("manguoidung");
            entity.Property(e => e.Trangthai)
                .HasDefaultValue(true)
                .HasColumnName("trangthai");

            entity.HasOne(d => d.MalopNavigation).WithMany(p => p.ChiTietLops)
                .HasForeignKey(d => d.Malop)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("FK__ChiTietNh__manho__04E4BC85");

            entity.HasOne(d => d.ManguoidungNavigation).WithMany(p => p.ChiTietLops)
                .HasForeignKey(d => d.Manguoidung)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("FK__ChiTietNh__mangu__05D8E0BE");
        });

        modelBuilder.Entity<ChiTietTraLoiSinhVien>(entity =>
        {
            entity.HasKey(e => e.Matraloichitiet);

            entity.ToTable("ChiTietTraLoiSinhVien");

            entity.Property(e => e.Matraloichitiet).HasColumnName("matraloichitiet");
            entity.Property(e => e.Dapansv).HasColumnName("dapansv");
            entity.Property(e => e.Macauhoi).HasColumnName("macauhoi");
            entity.Property(e => e.Macautl).HasColumnName("macautl");
            entity.Property(e => e.Makq).HasColumnName("makq");

            entity.HasOne(d => d.MacautlNavigation).WithMany(p => p.ChiTietTraLoiSinhViens)
                .HasForeignKey(d => d.Macautl)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("FK_ChiTietTraLoiSinhVien_CauTraLoi");

            entity.HasOne(d => d.ChiTietKetQua).WithMany(p => p.ChiTietTraLoiSinhViens)
                .HasForeignKey(d => new { d.Makq, d.Macauhoi })
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("FK_ChiTietTraLoiSinhVien_KetQua");
        });

        modelBuilder.Entity<Chuong>(entity =>
        {
            entity.HasKey(e => e.Machuong).HasName("PK__Chuong__3BE2D1BAE7A2D2AF");

            entity.ToTable("Chuong");

            entity.Property(e => e.Machuong).HasColumnName("machuong");
            entity.Property(e => e.Mamonhoc).HasColumnName("mamonhoc");
            entity.Property(e => e.Tenchuong)
                .HasMaxLength(100)
                .HasColumnName("tenchuong");
            entity.Property(e => e.Nguoitao)
                .HasMaxLength(50)
                .HasColumnName("nguoitao");
            entity.Property(e => e.Trangthai)
                .HasDefaultValue(true)
                .HasColumnName("trangthai");

            entity.HasOne(d => d.MamonhocNavigation).WithMany(p => p.Chuongs)
                .HasForeignKey(d => d.Mamonhoc)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("FK__Chuong__mamonhoc__08B54D69");
            entity.HasOne(d => d.NguoitaoNavigation).WithMany(p => p.Chuongs)
                .HasForeignKey(d => d.Nguoitao)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("FK_Chuong_NguoiDung");
        });

        modelBuilder.Entity<DeThi>(entity =>
        {
            entity.HasKey(e => e.Made).HasName("PK__DeThi__7A21E058535AB3D4");

            entity.ToTable("DeThi");

            entity.Property(e => e.Made).HasColumnName("made");
            entity.Property(e => e.Hienthibailam).HasColumnName("hienthibailam");
            entity.Property(e => e.Loaide).HasColumnName("loaide");
            entity.Property(e => e.Monthi).HasColumnName("monthi");
            entity.Property(e => e.Nguoitao)
                .HasMaxLength(50)
                .HasColumnName("nguoitao");
            entity.Property(e => e.Socaude).HasColumnName("socaude");
            entity.Property(e => e.Socaukho).HasColumnName("socaukho");
            entity.Property(e => e.Socautb).HasColumnName("socautb");
            entity.Property(e => e.Tende)
                .HasMaxLength(255)
                .HasColumnName("tende");
            entity.Property(e => e.Thoigianketthuc)
                .HasColumnType("datetime")
                .HasColumnName("thoigianketthuc");
            entity.Property(e => e.Thoigiantao)
                .HasDefaultValueSql("(getdate())")
                .HasColumnType("datetime")
                .HasColumnName("thoigiantao");
            entity.Property(e => e.Thoigiantbatdau)
                .HasColumnType("datetime")
                .HasColumnName("thoigiantbatdau");
            entity.Property(e => e.Thoigianthi).HasColumnName("thoigianthi");
            entity.Property(e => e.Trangthai)
                .HasDefaultValue(true)
                .HasColumnName("trangthai");
            entity.Property(e => e.Troncauhoi).HasColumnName("troncauhoi");
            entity.Property(e => e.Xemdapan).HasColumnName("xemdapan");
            entity.Property(e => e.Xemdiemthi).HasColumnName("xemdiemthi");

            entity.HasOne(d => d.NguoitaoNavigation).WithMany(p => p.DeThis)
                .HasForeignKey(d => d.Nguoitao)
                .HasConstraintName("FK_DeThi_NguoiDung");

            entity.HasMany(d => d.Malops).WithMany(p => p.Mades)
              .UsingEntity<Dictionary<string, object>>(
                  "GiaoDeThi",
                  r => r.HasOne<Lop>().WithMany()
                      .HasForeignKey("Malop")
                      .OnDelete(DeleteBehavior.ClientSetNull)
                      .HasConstraintName("FK__GiaoDeThi__manho__09A971A2"),
                  l => l.HasOne<DeThi>().WithMany()
                      .HasForeignKey("Made")
                      .OnDelete(DeleteBehavior.ClientSetNull)
                      .HasConstraintName("FK__GiaoDeThi__made__0A9D95DB"),
                  j =>
                  {
                      j.HasKey("Made", "Malop").HasName("PK__GiaoDeTh__59984D6E5E6CD5F1");
                      j.ToTable("GiaoDeThi");
                      j.IndexerProperty<int>("Made").HasColumnName("made");
                      j.IndexerProperty<int>("Malop").HasColumnName("malop");
                  });
        });

        modelBuilder.Entity<KetQua>(entity =>
        {
            entity.HasKey(e => new { e.Makq, e.Manguoidung }).HasName("PK__KetQua__08F4C84DCC478C58");

            entity.ToTable("KetQua");

            entity.HasIndex(e => e.Makq, "UQ__KetQua__7A21BB42CFFF991C").IsUnique();

            entity.Property(e => e.Makq)
                .ValueGeneratedOnAdd()
                .HasColumnName("makq");
            entity.Property(e => e.Manguoidung)
                .HasMaxLength(50)
                .HasDefaultValue("")
                .HasColumnName("manguoidung");
            entity.Property(e => e.Diemthi).HasColumnName("diemthi");
            entity.Property(e => e.Made).HasColumnName("made");
            entity.Property(e => e.Socaudung).HasColumnName("socaudung");
            entity.Property(e => e.Solanchuyentab)
                .HasDefaultValue(0)
                .HasColumnName("solanchuyentab");
            entity.Property(e => e.Thoigianlambai).HasColumnName("thoigianlambai");
            entity.Property(e => e.Thoigianvaothi)
                .HasDefaultValueSql("(getdate())")
                .HasColumnType("datetime")
                .HasColumnName("thoigianvaothi");

            entity.HasOne(d => d.MadeNavigation).WithMany(p => p.KetQuas)
                .HasForeignKey(d => d.Made)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("FK__KetQua__made__0B91BA14");

            entity.HasOne(d => d.ManguoidungNavigation).WithMany(p => p.KetQuas)
                .HasForeignKey(d => d.Manguoidung)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("FK__KetQua__manguoid__0C85DE4D");
        });

        modelBuilder.Entity<Lop>(entity =>
        {
            entity.HasKey(e => e.Malop).HasName("PK__Nhom__3B9AD363AD00C409");

            entity.ToTable("Lop");

            entity.Property(e => e.Malop).HasColumnName("malop");
            entity.Property(e => e.Ghichu)
                .HasMaxLength(255)
                .HasColumnName("ghichu");
            entity.Property(e => e.Giangvien)
                .HasMaxLength(50)
                .HasDefaultValue("")
                .HasColumnName("giangvien");
            entity.Property(e => e.Hienthi)
                .HasDefaultValue(true)
                .HasColumnName("hienthi");
            entity.Property(e => e.Hocky).HasColumnName("hocky");
            entity.Property(e => e.Mamoi)
                .HasMaxLength(50)
                .HasColumnName("mamoi");
            entity.Property(e => e.Namhoc).HasColumnName("namhoc");
            entity.Property(e => e.Siso)
                .HasDefaultValue(0)
                .HasColumnName("siso");
            entity.Property(e => e.Tenlop)
                .HasMaxLength(255)
                .HasColumnName("tenlop");
            entity.Property(e => e.Trangthai)
                .HasDefaultValue(true)
                .HasColumnName("trangthai");

            entity.HasOne(d => d.GiangvienNavigation).WithMany(p => p.Lops)
                .HasForeignKey(d => d.Giangvien)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("FK_Lop_NguoiDung");

        });

        modelBuilder.Entity<MonHoc>(entity =>
        {
            entity.HasKey(e => e.Mamonhoc).HasName("PK__MonHoc__A2CD2A19EB7BC4BE");

            entity.ToTable("MonHoc");

            entity.Property(e => e.Mamonhoc)
                .ValueGeneratedNever()
                .HasColumnName("mamonhoc");
            entity.Property(e => e.Sotietlythuyet).HasColumnName("sotietlythuyet");
            entity.Property(e => e.Sotietthuchanh).HasColumnName("sotietthuchanh");
            entity.Property(e => e.Sotinchi).HasColumnName("sotinchi");
            entity.Property(e => e.Tenmonhoc)
                .HasMaxLength(100)
                .HasColumnName("tenmonhoc");
            entity.Property(e => e.Trangthai)
                .HasDefaultValue(true)
                .HasColumnName("trangthai");
        });

        modelBuilder.Entity<DanhSachLop>(entity =>
        {
            entity.ToTable("DanhSachLop");

            entity.HasKey(e => new { e.Malop, e.Mamonhoc });

            entity.Property(e => e.Malop).HasColumnName("malop");
            entity.Property(e => e.Mamonhoc).HasColumnName("mamonhoc");

            entity.HasOne(e => e.MalopNavigation)
                .WithMany(l => l.DanhSachLops)
                .HasForeignKey(e => e.Malop)
                .OnDelete(DeleteBehavior.Restrict)
                .HasConstraintName("FK__DanhSachLop__Lop");

            entity.HasOne(e => e.MamonhocNavigation)
                .WithMany(mh => mh.DanhSachLops)
                .HasForeignKey(e => e.Mamonhoc)
                .OnDelete(DeleteBehavior.Restrict)
                .HasConstraintName("FK__DanhSachLop__MonHoc");
        });


        modelBuilder.Entity<NguoiDung>(entity =>
        {
            entity.HasKey(e => e.Id).HasName("PK__NguoiDun__3213E83F5455D483");

            entity.ToTable("NguoiDung");

            entity.Property(e => e.Id)
                .HasMaxLength(50)
                .HasColumnName("id");
            entity.Property(e => e.Avatar)
                .HasMaxLength(255)
                .HasColumnName("avatar");
            entity.Property(e => e.Email)
                .HasMaxLength(255)
                .HasColumnName("email");
            entity.Property(e => e.Gioitinh).HasColumnName("gioitinh");
            entity.Property(e => e.Hoten)
                .HasMaxLength(100)
                .HasColumnName("hoten");
            entity.Property(e => e.Ngaysinh)
                .HasDefaultValueSql("(NULL)")
                .HasColumnType("datetime")
                .HasColumnName("ngaysinh");
            entity.Property(e => e.Ngaythamgia)
                .HasDefaultValueSql("(getdate())")
                .HasColumnType("datetime")
                .HasColumnName("ngaythamgia");
            entity.Property(e => e.Trangthai)
                .HasDefaultValue(true)
                .HasColumnName("trangthai");
            entity.Property(e => e.Hienthi)
                .HasDefaultValue(true)
                .HasColumnName("hienthi");
            
        });

        modelBuilder.Entity<PhanCong>(entity =>
        {
            entity.HasKey(e => new { e.Mamonhoc, e.Manguoidung });

            entity.ToTable("PhanCong");

            entity.Property(e => e.Mamonhoc)
            .HasColumnName("mamonhoc");

            entity.Property(e => e.Manguoidung)
                .HasMaxLength(50)
                .HasDefaultValue("")
                .HasColumnName("manguoidung");

            entity.HasOne(e => e.MamonhocNavigation)
                .WithMany(m => m.PhanCongs)
                .HasForeignKey(e => e.Mamonhoc)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("FK__Giangvien__MonHoc");

            entity.HasOne(e => e.ManguoidungNavigation)
                .WithMany(nd => nd.PhanCongs)
                .HasForeignKey(e => e.Manguoidung)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("FK__Phancong__NguoiDung");

        });
        modelBuilder.Entity<ThongBao>(entity =>
        {
            entity.HasKey(e => e.Matb).HasName("PK__ThongBao__7A217E61B4725307");

            entity.ToTable("ThongBao");

            entity.Property(e => e.Matb).HasColumnName("matb");
            entity.Property(e => e.Nguoitao)
                .HasMaxLength(50)
                .HasDefaultValue("")
                .HasColumnName("nguoitao");
            entity.Property(e => e.Noidung)
                .HasMaxLength(255)
                .HasColumnName("noidung");
            entity.Property(e => e.Thoigiantao)
                .HasDefaultValueSql("(getdate())")
                .HasColumnType("datetime")
                .HasColumnName("thoigiantao");

            entity.HasOne(d => d.NguoitaoNavigation).WithMany(p => p.ThongBaos)
                .HasForeignKey(d => d.Nguoitao)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("FK_ThongBao_NguoiDung");

            entity.HasMany(d => d.Malops).WithMany(p => p.Matbs)
                .UsingEntity<Dictionary<string, object>>(
                    "ChiTietThongBao",
                    r => r.HasOne<Lop>().WithMany()
                        .HasForeignKey("Malop")
                        .OnDelete(DeleteBehavior.ClientSetNull)
                        .HasConstraintName("FK_ChiTietThongBao_ChiTietThongBao"),
                    l => l.HasOne<ThongBao>().WithMany()
                        .HasForeignKey("Matb")
                        .OnDelete(DeleteBehavior.ClientSetNull)
                        .HasConstraintName("FK_ChiTietThongBao_ThongBao"),
                    j =>
                    {
                        j.HasKey("Matb", "Malop");
                        j.ToTable("ChiTietThongBao");
                        j.IndexerProperty<int>("Matb").HasColumnName("matb");
                        j.IndexerProperty<int>("Malop").HasColumnName("malop");
                    });
        });

        modelBuilder.Entity<DanhMucChucNang>(entity =>
           {
               entity.ToTable("DanhMucChucNang");

               entity.HasKey(e => e.ChucNang);

               entity.Property(e => e.ChucNang)
                     .HasColumnName("chucnang")
                     .HasMaxLength(50);

               entity.Property(e => e.TenChucNang)
                     .HasColumnName("tenchucnang")
                     .HasMaxLength(255);

               entity.HasMany(e => e.ChiTietQuyens)
                     .WithOne(e => e.DanhMucChucNang)
                     .HasForeignKey(e => e.ChucNang)
                     .OnDelete(DeleteBehavior.Cascade);
           });


        modelBuilder.Entity<ChiTietQuyen>(entity =>
        {
            entity.ToTable("ChiTietQuyen");

            entity.HasKey(e => new { e.RoleId, e.ChucNang, e.HanhDong });


            entity.Property(e => e.RoleId)
            .HasColumnName("roleid");

            entity.Property(e => e.ChucNang)
            .HasMaxLength(50)
            .HasColumnName("chucnang");

            entity.Property(e => e.HanhDong)
            .HasMaxLength(50)
            .HasColumnName("hanhdong");

            entity.HasOne(d => d.RoleidNavigation)
                .WithMany(p => p.ChiTietQuyens)
                .HasForeignKey(d => d.RoleId)
                .OnDelete(DeleteBehavior.Cascade);

            entity.HasOne(d => d.DanhMucChucNang)
                .WithMany(p => p.ChiTietQuyens)
                .HasForeignKey(d => d.ChucNang)
                .OnDelete(DeleteBehavior.Cascade);
        });

        modelBuilder.Entity<ChiTietDeThiSinhVien>(entity =>
        {
            entity.HasKey(e => e.MachitietDTSV);

            entity.ToTable("ChiTietDeThiSinhVien");

            entity.Property(e => e.MachitietDTSV).HasColumnName("machitietDTSV");
            entity.Property(e => e.Id)
                .HasMaxLength(50)
                .HasColumnName("id");
            entity.Property(e => e.Made).HasColumnName("made");
            entity.Property(e => e.Macauhoi).HasColumnName("macauhoi");
            entity.Property(e => e.Diem).HasColumnName("diem");

            entity.HasOne(d => d.IdNavigation).WithMany()
                .HasForeignKey(d => d.Id)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("FK_ChiTietDeThiSinhVien_NguoiDung");

            entity.HasOne(d => d.MadeNavigation).WithMany()
                .HasForeignKey(d => d.Made)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("FK_ChiTietDeThiSinhVien_DeThi");

            entity.HasOne(d => d.MacauhoiNavigation).WithMany()
                .HasForeignKey(d => d.Macauhoi)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("FK_ChiTietDeThiSinhVien_CauHoi");
        });

        OnModelCreatingPartial(modelBuilder);
    }

    partial void OnModelCreatingPartial(ModelBuilder modelBuilder);
}
