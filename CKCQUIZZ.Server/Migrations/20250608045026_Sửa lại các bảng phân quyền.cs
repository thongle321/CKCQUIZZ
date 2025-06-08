using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace CKCQUIZZ.Server.Migrations
{
    /// <inheritdoc />
    public partial class Sửalạicácbảngphânquyền : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropTable(
                name: "HanhDong");

            migrationBuilder.DropTable(
                name: "PhuongThuc");

            migrationBuilder.DropTable(
                name: "PhuongThucHanhDong");

            migrationBuilder.DropTable(
                name: "Quyen");

            migrationBuilder.AddColumn<bool>(
                name: "ThamGiaHocPhan",
                table: "AspNetRoles",
                type: "bit",
                nullable: false,
                defaultValue: false);

            migrationBuilder.AddColumn<bool>(
                name: "ThamGiaThi",
                table: "AspNetRoles",
                type: "bit",
                nullable: false,
                defaultValue: false);

            migrationBuilder.AddColumn<bool>(
                name: "TrangThai",
                table: "AspNetRoles",
                type: "bit",
                nullable: false,
                defaultValue: false);

            migrationBuilder.CreateTable(
                name: "danhmucchucnang",
                columns: table => new
                {
                    chucnang = table.Column<string>(type: "nvarchar(50)", maxLength: 50, nullable: false),
                    tenchucnang = table.Column<string>(type: "nvarchar(255)", maxLength: 255, nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_danhmucchucnang", x => x.chucnang);
                });

            migrationBuilder.CreateTable(
                name: "ChiTietQuyen",
                columns: table => new
                {
                    roleid = table.Column<string>(type: "varchar(50)", nullable: false),
                    chucnang = table.Column<string>(type: "nvarchar(50)", maxLength: 50, nullable: false),
                    hanhdong = table.Column<string>(type: "nvarchar(50)", maxLength: 50, nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_ChiTietQuyen", x => new { x.roleid, x.chucnang, x.hanhdong });
                    table.ForeignKey(
                        name: "FK_ChiTietQuyen_AspNetRoles_roleid",
                        column: x => x.roleid,
                        principalTable: "AspNetRoles",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                    table.ForeignKey(
                        name: "FK_ChiTietQuyen_danhmucchucnang_chucnang",
                        column: x => x.chucnang,
                        principalTable: "danhmucchucnang",
                        principalColumn: "chucnang",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateIndex(
                name: "IX_ChiTietQuyen_chucnang",
                table: "ChiTietQuyen",
                column: "chucnang");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropTable(
                name: "ChiTietQuyen");

            migrationBuilder.DropTable(
                name: "danhmucchucnang");

            migrationBuilder.DropColumn(
                name: "ThamGiaHocPhan",
                table: "AspNetRoles");

            migrationBuilder.DropColumn(
                name: "ThamGiaThi",
                table: "AspNetRoles");

            migrationBuilder.DropColumn(
                name: "TrangThai",
                table: "AspNetRoles");

            migrationBuilder.CreateTable(
                name: "HanhDong",
                columns: table => new
                {
                    mahanhdong = table.Column<string>(type: "nvarchar(50)", maxLength: 50, nullable: false),
                    ten = table.Column<string>(type: "nvarchar(50)", maxLength: 50, nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK__HanhDong", x => x.mahanhdong);
                });

            migrationBuilder.CreateTable(
                name: "PhuongThuc",
                columns: table => new
                {
                    maphuongthuc = table.Column<string>(type: "varchar(50)", maxLength: 50, nullable: false),
                    ten = table.Column<string>(type: "nvarchar(200)", maxLength: 200, nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK__PhuongThuc", x => x.maphuongthuc);
                });

            migrationBuilder.CreateTable(
                name: "PhuongThucHanhDong",
                columns: table => new
                {
                    mahanhdong = table.Column<string>(type: "varchar(50)", maxLength: 50, nullable: false),
                    maphuongthuc = table.Column<string>(type: "varchar(50)", maxLength: 50, nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_PhuongThucHanhDong", x => new { x.mahanhdong, x.maphuongthuc });
                });

            migrationBuilder.CreateTable(
                name: "Quyen",
                columns: table => new
                {
                    maquyen = table.Column<string>(type: "varchar(50)", maxLength: 50, nullable: false),
                    maphuongthuc = table.Column<string>(type: "varchar(50)", maxLength: 50, nullable: false),
                    mahanhdong = table.Column<string>(type: "varchar(50)", maxLength: 50, nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_Quyen", x => new { x.maquyen, x.maphuongthuc, x.mahanhdong });
                });
        }
    }
}
