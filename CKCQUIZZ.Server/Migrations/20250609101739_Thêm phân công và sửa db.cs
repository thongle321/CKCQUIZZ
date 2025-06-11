using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace CKCQUIZZ.Server.Migrations
{
    /// <inheritdoc />
    public partial class Thêmphâncôngvàsửadb : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.RenameColumn(
                name: "Mamonhoc",
                table: "DanhSachLop",
                newName: "mamonhoc");

            migrationBuilder.RenameColumn(
                name: "Malop",
                table: "DanhSachLop",
                newName: "malop");

            migrationBuilder.RenameIndex(
                name: "IX_DanhSachLop_Mamonhoc",
                table: "DanhSachLop",
                newName: "IX_DanhSachLop_mamonhoc");

            migrationBuilder.CreateTable(
                name: "PhanCong",
                columns: table => new
                {
                    mamonhoc = table.Column<int>(type: "int", nullable: false),
                    manguoidung = table.Column<string>(type: "nvarchar(50)", maxLength: 50, nullable: false, defaultValue: "")
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_PhanCong", x => new { x.mamonhoc, x.manguoidung });
                    table.ForeignKey(
                        name: "FK__Giangvien__MonHoc",
                        column: x => x.mamonhoc,
                        principalTable: "MonHoc",
                        principalColumn: "mamonhoc");
                    table.ForeignKey(
                        name: "FK__Phancong__NguoiDung",
                        column: x => x.manguoidung,
                        principalTable: "NguoiDung",
                        principalColumn: "id");
                });

            migrationBuilder.CreateIndex(
                name: "IX_PhanCong_manguoidung",
                table: "PhanCong",
                column: "manguoidung");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropTable(
                name: "PhanCong");

            migrationBuilder.RenameColumn(
                name: "mamonhoc",
                table: "DanhSachLop",
                newName: "Mamonhoc");

            migrationBuilder.RenameColumn(
                name: "malop",
                table: "DanhSachLop",
                newName: "Malop");

            migrationBuilder.RenameIndex(
                name: "IX_DanhSachLop_mamonhoc",
                table: "DanhSachLop",
                newName: "IX_DanhSachLop_Mamonhoc");
        }
    }
}
