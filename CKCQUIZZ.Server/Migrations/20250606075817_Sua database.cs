using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace CKCQUIZZ.Server.Migrations
{
    /// <inheritdoc />
    public partial class Suadatabase : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropForeignKey(
                name: "FK__NguoiDung__manho__0D7A0286",
                table: "NguoiDung");

            migrationBuilder.DropTable(
                name: "NhomQuyen");

            migrationBuilder.DropIndex(
                name: "IX_NguoiDung_manhomquyen",
                table: "NguoiDung");

            migrationBuilder.DropColumn(
                name: "manhomquyen",
                table: "NguoiDung");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<int>(
                name: "manhomquyen",
                table: "NguoiDung",
                type: "int",
                nullable: true);

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

            migrationBuilder.CreateIndex(
                name: "IX_NguoiDung_manhomquyen",
                table: "NguoiDung",
                column: "manhomquyen");

            migrationBuilder.AddForeignKey(
                name: "FK__NguoiDung__manho__0D7A0286",
                table: "NguoiDung",
                column: "manhomquyen",
                principalTable: "NhomQuyen",
                principalColumn: "manhomquyen");
        }
    }
}
