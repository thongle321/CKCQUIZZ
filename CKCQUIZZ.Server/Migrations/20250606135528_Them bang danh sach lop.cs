using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace CKCQUIZZ.Server.Migrations
{
    /// <inheritdoc />
    public partial class Thembangdanhsachlop : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.CreateTable(
                name: "DanhSachLop",
                columns: table => new
                {
                    Malop = table.Column<int>(type: "int", nullable: false),
                    Mamonhoc = table.Column<int>(type: "int", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_DanhSachLop", x => new { x.Malop, x.Mamonhoc });
                    table.ForeignKey(
                        name: "FK__DanhSachLop__Lop",
                        column: x => x.Malop,
                        principalTable: "Lop",
                        principalColumn: "malop",
                        onDelete: ReferentialAction.Restrict);
                    table.ForeignKey(
                        name: "FK__DanhSachLop__MonHoc",
                        column: x => x.Mamonhoc,
                        principalTable: "MonHoc",
                        principalColumn: "mamonhoc",
                        onDelete: ReferentialAction.Restrict);
                });

            migrationBuilder.CreateIndex(
                name: "IX_DanhSachLop_Mamonhoc",
                table: "DanhSachLop",
                column: "Mamonhoc");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropTable(
                name: "DanhSachLop");
        }
    }
}
