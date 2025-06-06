using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace CKCQUIZZ.Server.Migrations
{
    /// <inheritdoc />
    public partial class Initial : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.CreateTable(
                name: "AspNetRoles",
                columns: table => new
                {
                    Id = table.Column<string>(type: "varchar(50)", unicode: false, maxLength: 50, nullable: false),
                    Name = table.Column<string>(type: "nvarchar(256)", maxLength: 256, nullable: true),
                    NormalizedName = table.Column<string>(type: "nvarchar(256)", maxLength: 256, nullable: true),
                    ConcurrencyStamp = table.Column<string>(type: "nvarchar(max)", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_AspNetRoles", x => x.Id);
                });

            migrationBuilder.CreateTable(
                name: "MonHoc",
                columns: table => new
                {
                    mamonhoc = table.Column<int>(type: "int", nullable: false),
                    tenmonhoc = table.Column<string>(type: "nvarchar(100)", maxLength: 100, nullable: false),
                    sotinchi = table.Column<int>(type: "int", nullable: false),
                    sotietlythuyet = table.Column<int>(type: "int", nullable: false),
                    sotietthuchanh = table.Column<int>(type: "int", nullable: false),
                    trangthai = table.Column<bool>(type: "bit", nullable: false, defaultValue: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK__MonHoc__A2CD2A19EB7BC4BE", x => x.mamonhoc);
                });

            migrationBuilder.CreateTable(
                name: "NhomQuyen",
                columns: table => new
                {
                    manhomquyen = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    tennhomquyen = table.Column<string>(type: "nvarchar(50)", maxLength: 50, nullable: false),
                    trangthai = table.Column<bool>(type: "bit", nullable: false, defaultValue: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK__NhomQuye__550F474EE42BB2C8", x => x.manhomquyen);
                });

            migrationBuilder.CreateTable(
                name: "AspNetRoleClaims",
                columns: table => new
                {
                    Id = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    RoleId = table.Column<string>(type: "varchar(50)", nullable: false),
                    ClaimType = table.Column<string>(type: "nvarchar(max)", nullable: true),
                    ClaimValue = table.Column<string>(type: "nvarchar(max)", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_AspNetRoleClaims", x => x.Id);
                    table.ForeignKey(
                        name: "FK_AspNetRoleClaims_AspNetRoles_RoleId",
                        column: x => x.RoleId,
                        principalTable: "AspNetRoles",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateTable(
                name: "Chuong",
                columns: table => new
                {
                    machuong = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    tenchuong = table.Column<string>(type: "nvarchar(100)", maxLength: 100, nullable: false),
                    mamonhoc = table.Column<int>(type: "int", nullable: false),
                    trangthai = table.Column<bool>(type: "bit", nullable: true, defaultValue: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK__Chuong__3BE2D1BAE7A2D2AF", x => x.machuong);
                    table.ForeignKey(
                        name: "FK__Chuong__mamonhoc__08B54D69",
                        column: x => x.mamonhoc,
                        principalTable: "MonHoc",
                        principalColumn: "mamonhoc");
                });

            migrationBuilder.CreateTable(
                name: "NguoiDung",
                columns: table => new
                {
                    id = table.Column<string>(type: "nvarchar(50)", maxLength: 50, nullable: false),
                    hoten = table.Column<string>(type: "nvarchar(100)", maxLength: 100, nullable: false),
                    gioitinh = table.Column<bool>(type: "bit", nullable: true),
                    ngaysinh = table.Column<DateTime>(type: "datetime", nullable: true, defaultValueSql: "(NULL)"),
                    avatar = table.Column<string>(type: "nvarchar(255)", maxLength: 255, nullable: true),
                    ngaythamgia = table.Column<DateTime>(type: "datetime", nullable: false, defaultValueSql: "(getdate())"),
                    trangthai = table.Column<bool>(type: "bit", nullable: true, defaultValue: true),
                    manhomquyen = table.Column<int>(type: "int", nullable: true),
                    RefreshToken = table.Column<string>(type: "nvarchar(max)", nullable: true),
                    RefreshTokenExpiryTime = table.Column<DateTime>(type: "datetime2", nullable: true),
                    UserName = table.Column<string>(type: "nvarchar(256)", maxLength: 256, nullable: true),
                    NormalizedUserName = table.Column<string>(type: "nvarchar(256)", maxLength: 256, nullable: true),
                    email = table.Column<string>(type: "nvarchar(255)", maxLength: 255, nullable: true),
                    NormalizedEmail = table.Column<string>(type: "nvarchar(256)", maxLength: 256, nullable: true),
                    EmailConfirmed = table.Column<bool>(type: "bit", nullable: false),
                    PasswordHash = table.Column<string>(type: "nvarchar(max)", nullable: true),
                    SecurityStamp = table.Column<string>(type: "nvarchar(max)", nullable: true),
                    ConcurrencyStamp = table.Column<string>(type: "nvarchar(max)", nullable: true),
                    PhoneNumber = table.Column<string>(type: "nvarchar(max)", nullable: true),
                    PhoneNumberConfirmed = table.Column<bool>(type: "bit", nullable: false),
                    TwoFactorEnabled = table.Column<bool>(type: "bit", nullable: false),
                    LockoutEnd = table.Column<DateTimeOffset>(type: "datetimeoffset", nullable: true),
                    LockoutEnabled = table.Column<bool>(type: "bit", nullable: false),
                    AccessFailedCount = table.Column<int>(type: "int", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK__NguoiDun__3213E83F5455D483", x => x.id);
                    table.ForeignKey(
                        name: "FK__NguoiDung__manho__0D7A0286",
                        column: x => x.manhomquyen,
                        principalTable: "NhomQuyen",
                        principalColumn: "manhomquyen");
                });

            migrationBuilder.CreateTable(
                name: "AspNetUserClaims",
                columns: table => new
                {
                    Id = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    UserId = table.Column<string>(type: "nvarchar(50)", nullable: false),
                    ClaimType = table.Column<string>(type: "nvarchar(max)", nullable: true),
                    ClaimValue = table.Column<string>(type: "nvarchar(max)", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_AspNetUserClaims", x => x.Id);
                    table.ForeignKey(
                        name: "FK_AspNetUserClaims_NguoiDung_UserId",
                        column: x => x.UserId,
                        principalTable: "NguoiDung",
                        principalColumn: "id",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateTable(
                name: "AspNetUserLogins",
                columns: table => new
                {
                    LoginProvider = table.Column<string>(type: "nvarchar(450)", nullable: false),
                    ProviderKey = table.Column<string>(type: "nvarchar(450)", nullable: false),
                    ProviderDisplayName = table.Column<string>(type: "nvarchar(max)", nullable: true),
                    UserId = table.Column<string>(type: "nvarchar(50)", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_AspNetUserLogins", x => new { x.LoginProvider, x.ProviderKey });
                    table.ForeignKey(
                        name: "FK_AspNetUserLogins_NguoiDung_UserId",
                        column: x => x.UserId,
                        principalTable: "NguoiDung",
                        principalColumn: "id",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateTable(
                name: "AspNetUserRoles",
                columns: table => new
                {
                    UserId = table.Column<string>(type: "nvarchar(50)", nullable: false),
                    RoleId = table.Column<string>(type: "varchar(50)", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_AspNetUserRoles", x => new { x.UserId, x.RoleId });
                    table.ForeignKey(
                        name: "FK_AspNetUserRoles_AspNetRoles_RoleId",
                        column: x => x.RoleId,
                        principalTable: "AspNetRoles",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                    table.ForeignKey(
                        name: "FK_AspNetUserRoles_NguoiDung_UserId",
                        column: x => x.UserId,
                        principalTable: "NguoiDung",
                        principalColumn: "id",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateTable(
                name: "AspNetUserTokens",
                columns: table => new
                {
                    UserId = table.Column<string>(type: "nvarchar(50)", nullable: false),
                    LoginProvider = table.Column<string>(type: "nvarchar(450)", nullable: false),
                    Name = table.Column<string>(type: "nvarchar(450)", nullable: false),
                    Value = table.Column<string>(type: "nvarchar(max)", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_AspNetUserTokens", x => new { x.UserId, x.LoginProvider, x.Name });
                    table.ForeignKey(
                        name: "FK_AspNetUserTokens_NguoiDung_UserId",
                        column: x => x.UserId,
                        principalTable: "NguoiDung",
                        principalColumn: "id",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateTable(
                name: "CauHoi",
                columns: table => new
                {
                    macauhoi = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    noidung = table.Column<string>(type: "nvarchar(500)", maxLength: 500, nullable: false),
                    dokho = table.Column<int>(type: "int", nullable: false),
                    mamonhoc = table.Column<int>(type: "int", nullable: false),
                    machuong = table.Column<int>(type: "int", nullable: false),
                    nguoitao = table.Column<string>(type: "nvarchar(50)", maxLength: 50, nullable: true),
                    daodapan = table.Column<bool>(type: "bit", nullable: true),
                    trangthai = table.Column<bool>(type: "bit", nullable: false, defaultValue: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK__CauHoi__95E62F03B214AAA6", x => x.macauhoi);
                    table.ForeignKey(
                        name: "FK_CauHoi_NguoiDung",
                        column: x => x.nguoitao,
                        principalTable: "NguoiDung",
                        principalColumn: "id");
                    table.ForeignKey(
                        name: "FK__CauHoi__machuong__7D439ABD",
                        column: x => x.machuong,
                        principalTable: "Chuong",
                        principalColumn: "machuong");
                    table.ForeignKey(
                        name: "FK__CauHoi__mamonhoc__7E37BEF6",
                        column: x => x.mamonhoc,
                        principalTable: "MonHoc",
                        principalColumn: "mamonhoc");
                });

            migrationBuilder.CreateTable(
                name: "DeThi",
                columns: table => new
                {
                    made = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    monthi = table.Column<int>(type: "int", nullable: true),
                    nguoitao = table.Column<string>(type: "nvarchar(50)", maxLength: 50, nullable: true),
                    tende = table.Column<string>(type: "nvarchar(255)", maxLength: 255, nullable: true),
                    thoigiantao = table.Column<DateTime>(type: "datetime", nullable: true, defaultValueSql: "(getdate())"),
                    thoigianthi = table.Column<int>(type: "int", nullable: true),
                    thoigiantbatdau = table.Column<DateTime>(type: "datetime", nullable: true),
                    thoigianketthuc = table.Column<DateTime>(type: "datetime", nullable: true),
                    hienthibailam = table.Column<bool>(type: "bit", nullable: true),
                    xemdiemthi = table.Column<bool>(type: "bit", nullable: true),
                    xemdapan = table.Column<bool>(type: "bit", nullable: true),
                    troncauhoi = table.Column<bool>(type: "bit", nullable: true),
                    loaide = table.Column<int>(type: "int", nullable: true),
                    socaude = table.Column<int>(type: "int", nullable: true),
                    socautb = table.Column<int>(type: "int", nullable: true),
                    socaukho = table.Column<int>(type: "int", nullable: true),
                    trangthai = table.Column<bool>(type: "bit", nullable: true, defaultValue: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK__DeThi__7A21E058535AB3D4", x => x.made);
                    table.ForeignKey(
                        name: "FK_DeThi_NguoiDung",
                        column: x => x.nguoitao,
                        principalTable: "NguoiDung",
                        principalColumn: "id");
                });

            migrationBuilder.CreateTable(
                name: "Lop",
                columns: table => new
                {
                    malop = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    tenlop = table.Column<string>(type: "nvarchar(255)", maxLength: 255, nullable: false),
                    mamoi = table.Column<string>(type: "nvarchar(50)", maxLength: 50, nullable: true),
                    siso = table.Column<byte>(type: "tinyint", nullable: true, defaultValue: (byte)0),
                    ghichu = table.Column<string>(type: "nvarchar(255)", maxLength: 255, nullable: true),
                    namhoc = table.Column<int>(type: "int", nullable: true),
                    hocky = table.Column<int>(type: "int", nullable: true),
                    trangthai = table.Column<bool>(type: "bit", nullable: true, defaultValue: true),
                    hienthi = table.Column<bool>(type: "bit", nullable: true, defaultValue: true),
                    giangvien = table.Column<string>(type: "nvarchar(50)", maxLength: 50, nullable: false, defaultValue: ""),
                    mamonhoc = table.Column<int>(type: "int", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK__Nhom__3B9AD363AD00C409", x => x.malop);
                    table.ForeignKey(
                        name: "FK_Lop_NguoiDung",
                        column: x => x.giangvien,
                        principalTable: "NguoiDung",
                        principalColumn: "id");
                    table.ForeignKey(
                        name: "FK__Nhom__mamonhoc__0E6E26BF",
                        column: x => x.mamonhoc,
                        principalTable: "MonHoc",
                        principalColumn: "mamonhoc");
                });

            migrationBuilder.CreateTable(
                name: "ThongBao",
                columns: table => new
                {
                    matb = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    noidung = table.Column<string>(type: "nvarchar(255)", maxLength: 255, nullable: true),
                    thoigiantao = table.Column<DateTime>(type: "datetime", nullable: true, defaultValueSql: "(getdate())"),
                    nguoitao = table.Column<string>(type: "nvarchar(50)", maxLength: 50, nullable: false, defaultValue: "")
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK__ThongBao__7A217E61B4725307", x => x.matb);
                    table.ForeignKey(
                        name: "FK_ThongBao_NguoiDung",
                        column: x => x.nguoitao,
                        principalTable: "NguoiDung",
                        principalColumn: "id");
                });

            migrationBuilder.CreateTable(
                name: "CauTraLoi",
                columns: table => new
                {
                    macautl = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    macauhoi = table.Column<int>(type: "int", nullable: false),
                    noidungtl = table.Column<string>(type: "nvarchar(500)", maxLength: 500, nullable: false),
                    cautltuluan = table.Column<string>(type: "nvarchar(50)", maxLength: 50, nullable: true),
                    hinhanh = table.Column<string>(type: "varchar(max)", unicode: false, nullable: true),
                    dapan = table.Column<bool>(type: "bit", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK__CauTraLo__190C43E2D12394B7", x => x.macautl);
                    table.ForeignKey(
                        name: "FK__CauTraLoi__macau__7F2BE32F",
                        column: x => x.macauhoi,
                        principalTable: "CauHoi",
                        principalColumn: "macauhoi");
                });

            migrationBuilder.CreateTable(
                name: "ChiTietDeThi",
                columns: table => new
                {
                    made = table.Column<int>(type: "int", nullable: false),
                    macauhoi = table.Column<int>(type: "int", nullable: false),
                    diemcauhoi = table.Column<double>(type: "float", nullable: false),
                    thutu = table.Column<int>(type: "int", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK__ChiTietD__537F82A8D7C214BF", x => new { x.made, x.macauhoi });
                    table.ForeignKey(
                        name: "FK__ChiTietDeT__made__01142BA1",
                        column: x => x.made,
                        principalTable: "DeThi",
                        principalColumn: "made");
                    table.ForeignKey(
                        name: "FK__ChiTietDe__macau__00200768",
                        column: x => x.macauhoi,
                        principalTable: "CauHoi",
                        principalColumn: "macauhoi");
                });

            migrationBuilder.CreateTable(
                name: "KetQua",
                columns: table => new
                {
                    makq = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    manguoidung = table.Column<string>(type: "nvarchar(50)", maxLength: 50, nullable: false, defaultValue: ""),
                    made = table.Column<int>(type: "int", nullable: false),
                    diemthi = table.Column<double>(type: "float", nullable: true),
                    thoigianvaothi = table.Column<DateTime>(type: "datetime", nullable: true, defaultValueSql: "(getdate())"),
                    thoigiansolambai = table.Column<int>(type: "int", nullable: true),
                    socaudung = table.Column<int>(type: "int", nullable: true),
                    solanchuyentab = table.Column<int>(type: "int", nullable: true, defaultValue: 0)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK__KetQua__08F4C84DCC478C58", x => new { x.makq, x.manguoidung });
                    table.UniqueConstraint("AK_KetQua_makq", x => x.makq);
                    table.ForeignKey(
                        name: "FK__KetQua__made__0B91BA14",
                        column: x => x.made,
                        principalTable: "DeThi",
                        principalColumn: "made");
                    table.ForeignKey(
                        name: "FK__KetQua__manguoid__0C85DE4D",
                        column: x => x.manguoidung,
                        principalTable: "NguoiDung",
                        principalColumn: "id");
                });

            migrationBuilder.CreateTable(
                name: "ChiTietLop",
                columns: table => new
                {
                    malop = table.Column<int>(type: "int", nullable: false),
                    manguoidung = table.Column<string>(type: "nvarchar(50)", maxLength: 50, nullable: false, defaultValue: "0"),
                    trangthai = table.Column<bool>(type: "bit", nullable: true, defaultValue: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK__ChiTietN__494FA06D1DCEF6FB", x => new { x.malop, x.manguoidung });
                    table.ForeignKey(
                        name: "FK__ChiTietNh__mangu__05D8E0BE",
                        column: x => x.manguoidung,
                        principalTable: "NguoiDung",
                        principalColumn: "id");
                    table.ForeignKey(
                        name: "FK__ChiTietNh__manho__04E4BC85",
                        column: x => x.malop,
                        principalTable: "Lop",
                        principalColumn: "malop");
                });

            migrationBuilder.CreateTable(
                name: "GiaoDeThi",
                columns: table => new
                {
                    made = table.Column<int>(type: "int", nullable: false),
                    malop = table.Column<int>(type: "int", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK__GiaoDeTh__59984D6E5E6CD5F1", x => new { x.made, x.malop });
                    table.ForeignKey(
                        name: "FK__GiaoDeThi__made__0A9D95DB",
                        column: x => x.made,
                        principalTable: "DeThi",
                        principalColumn: "made");
                    table.ForeignKey(
                        name: "FK__GiaoDeThi__manho__09A971A2",
                        column: x => x.malop,
                        principalTable: "Lop",
                        principalColumn: "malop");
                });

            migrationBuilder.CreateTable(
                name: "ChiTietThongBao",
                columns: table => new
                {
                    matb = table.Column<int>(type: "int", nullable: false),
                    malop = table.Column<int>(type: "int", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_ChiTietThongBao", x => new { x.matb, x.malop });
                    table.ForeignKey(
                        name: "FK_ChiTietThongBao_ChiTietThongBao",
                        column: x => x.malop,
                        principalTable: "Lop",
                        principalColumn: "malop");
                    table.ForeignKey(
                        name: "FK_ChiTietThongBao_ThongBao",
                        column: x => x.matb,
                        principalTable: "ThongBao",
                        principalColumn: "matb");
                });

            migrationBuilder.CreateTable(
                name: "ChiTietKetQua",
                columns: table => new
                {
                    makq = table.Column<int>(type: "int", nullable: false),
                    macauhoi = table.Column<int>(type: "int", nullable: false),
                    diemketqua = table.Column<double>(type: "float", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK__ChiTietK__537FD9B3DDAB731B", x => new { x.makq, x.macauhoi });
                    table.ForeignKey(
                        name: "FK__ChiTietKe__macau__02084FDA",
                        column: x => x.macauhoi,
                        principalTable: "CauHoi",
                        principalColumn: "macauhoi");
                    table.ForeignKey(
                        name: "FK__ChiTietKet__makq__03F0984C",
                        column: x => x.makq,
                        principalTable: "KetQua",
                        principalColumn: "makq");
                });

            migrationBuilder.CreateTable(
                name: "ChiTietTraLoiSinhVien",
                columns: table => new
                {
                    matraloichitiet = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    makq = table.Column<int>(type: "int", nullable: false),
                    macauhoi = table.Column<int>(type: "int", nullable: false),
                    macautl = table.Column<int>(type: "int", nullable: false),
                    dapansv = table.Column<int>(type: "int", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_ChiTietTraLoiSinhVien", x => x.matraloichitiet);
                    table.ForeignKey(
                        name: "FK_ChiTietTraLoiSinhVien_CauTraLoi",
                        column: x => x.macautl,
                        principalTable: "CauTraLoi",
                        principalColumn: "macautl");
                    table.ForeignKey(
                        name: "FK_ChiTietTraLoiSinhVien_KetQua",
                        columns: x => new { x.makq, x.macauhoi },
                        principalTable: "ChiTietKetQua",
                        principalColumns: new[] { "makq", "macauhoi" });
                });

            migrationBuilder.CreateIndex(
                name: "IX_AspNetRoleClaims_RoleId",
                table: "AspNetRoleClaims",
                column: "RoleId");

            migrationBuilder.CreateIndex(
                name: "RoleNameIndex",
                table: "AspNetRoles",
                column: "NormalizedName",
                unique: true,
                filter: "[NormalizedName] IS NOT NULL");

            migrationBuilder.CreateIndex(
                name: "IX_AspNetUserClaims_UserId",
                table: "AspNetUserClaims",
                column: "UserId");

            migrationBuilder.CreateIndex(
                name: "IX_AspNetUserLogins_UserId",
                table: "AspNetUserLogins",
                column: "UserId");

            migrationBuilder.CreateIndex(
                name: "IX_AspNetUserRoles_RoleId",
                table: "AspNetUserRoles",
                column: "RoleId");

            migrationBuilder.CreateIndex(
                name: "IX_CauHoi_machuong",
                table: "CauHoi",
                column: "machuong");

            migrationBuilder.CreateIndex(
                name: "IX_CauHoi_mamonhoc",
                table: "CauHoi",
                column: "mamonhoc");

            migrationBuilder.CreateIndex(
                name: "IX_CauHoi_nguoitao",
                table: "CauHoi",
                column: "nguoitao");

            migrationBuilder.CreateIndex(
                name: "IX_CauTraLoi_macauhoi",
                table: "CauTraLoi",
                column: "macauhoi");

            migrationBuilder.CreateIndex(
                name: "IX_ChiTietDeThi_macauhoi",
                table: "ChiTietDeThi",
                column: "macauhoi");

            migrationBuilder.CreateIndex(
                name: "IX_ChiTietKetQua_macauhoi",
                table: "ChiTietKetQua",
                column: "macauhoi");

            migrationBuilder.CreateIndex(
                name: "IX_ChiTietLop_manguoidung",
                table: "ChiTietLop",
                column: "manguoidung");

            migrationBuilder.CreateIndex(
                name: "IX_ChiTietThongBao_malop",
                table: "ChiTietThongBao",
                column: "malop");

            migrationBuilder.CreateIndex(
                name: "IX_ChiTietTraLoiSinhVien_macautl",
                table: "ChiTietTraLoiSinhVien",
                column: "macautl");

            migrationBuilder.CreateIndex(
                name: "IX_ChiTietTraLoiSinhVien_makq_macauhoi",
                table: "ChiTietTraLoiSinhVien",
                columns: new[] { "makq", "macauhoi" });

            migrationBuilder.CreateIndex(
                name: "IX_Chuong_mamonhoc",
                table: "Chuong",
                column: "mamonhoc");

            migrationBuilder.CreateIndex(
                name: "IX_DeThi_nguoitao",
                table: "DeThi",
                column: "nguoitao");

            migrationBuilder.CreateIndex(
                name: "IX_GiaoDeThi_malop",
                table: "GiaoDeThi",
                column: "malop");

            migrationBuilder.CreateIndex(
                name: "IX_KetQua_made",
                table: "KetQua",
                column: "made");

            migrationBuilder.CreateIndex(
                name: "IX_KetQua_manguoidung",
                table: "KetQua",
                column: "manguoidung");

            migrationBuilder.CreateIndex(
                name: "UQ__KetQua__7A21BB42CFFF991C",
                table: "KetQua",
                column: "makq",
                unique: true);

            migrationBuilder.CreateIndex(
                name: "IX_Lop_giangvien",
                table: "Lop",
                column: "giangvien");

            migrationBuilder.CreateIndex(
                name: "IX_Lop_mamonhoc",
                table: "Lop",
                column: "mamonhoc");

            migrationBuilder.CreateIndex(
                name: "EmailIndex",
                table: "NguoiDung",
                column: "NormalizedEmail");

            migrationBuilder.CreateIndex(
                name: "IX_NguoiDung_manhomquyen",
                table: "NguoiDung",
                column: "manhomquyen");

            migrationBuilder.CreateIndex(
                name: "UserNameIndex",
                table: "NguoiDung",
                column: "NormalizedUserName",
                unique: true,
                filter: "[NormalizedUserName] IS NOT NULL");

            migrationBuilder.CreateIndex(
                name: "IX_ThongBao_nguoitao",
                table: "ThongBao",
                column: "nguoitao");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropTable(
                name: "AspNetRoleClaims");

            migrationBuilder.DropTable(
                name: "AspNetUserClaims");

            migrationBuilder.DropTable(
                name: "AspNetUserLogins");

            migrationBuilder.DropTable(
                name: "AspNetUserRoles");

            migrationBuilder.DropTable(
                name: "AspNetUserTokens");

            migrationBuilder.DropTable(
                name: "ChiTietDeThi");

            migrationBuilder.DropTable(
                name: "ChiTietLop");

            migrationBuilder.DropTable(
                name: "ChiTietThongBao");

            migrationBuilder.DropTable(
                name: "ChiTietTraLoiSinhVien");

            migrationBuilder.DropTable(
                name: "GiaoDeThi");

            migrationBuilder.DropTable(
                name: "AspNetRoles");

            migrationBuilder.DropTable(
                name: "ThongBao");

            migrationBuilder.DropTable(
                name: "CauTraLoi");

            migrationBuilder.DropTable(
                name: "ChiTietKetQua");

            migrationBuilder.DropTable(
                name: "Lop");

            migrationBuilder.DropTable(
                name: "CauHoi");

            migrationBuilder.DropTable(
                name: "KetQua");

            migrationBuilder.DropTable(
                name: "Chuong");

            migrationBuilder.DropTable(
                name: "DeThi");

            migrationBuilder.DropTable(
                name: "MonHoc");

            migrationBuilder.DropTable(
                name: "NguoiDung");

            migrationBuilder.DropTable(
                name: "NhomQuyen");
        }
    }
}
