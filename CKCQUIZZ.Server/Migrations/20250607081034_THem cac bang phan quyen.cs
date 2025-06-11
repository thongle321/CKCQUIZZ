using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace CKCQUIZZ.Server.Migrations
{
    /// <inheritdoc />
    public partial class THemcacbangphanquyen : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
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
                    maphuongthuc = table.Column<string>(type: "varchar(50)", maxLength: 50, nullable: false),
                    maquyen = table.Column<string>(type: "varchar(50)", maxLength: 50, nullable: false),
                    mahanhdong = table.Column<string>(type: "varchar(50)", maxLength: 50, nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_Quyen", x => new { x.maquyen, x.maphuongthuc, x.mahanhdong });
                });
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropTable(
                name: "HanhDong");

            migrationBuilder.DropTable(
                name: "PhuongThuc");

            migrationBuilder.DropTable(
                name: "PhuongThucHanhDong");

            migrationBuilder.DropTable(
                name: "Quyen");
        }
    }
}
