using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace CKCQUIZZ.Server.Migrations
{
    /// <inheritdoc />
    public partial class Suadatabaselop : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropForeignKey(
                name: "FK__Nhom__mamonhoc__0E6E26BF",
                table: "Lop");

            migrationBuilder.DropIndex(
                name: "IX_Lop_mamonhoc",
                table: "Lop");

            migrationBuilder.DropColumn(
                name: "mamonhoc",
                table: "Lop");

            migrationBuilder.AddColumn<int>(
                name: "MonHocMamonhoc",
                table: "Lop",
                type: "int",
                nullable: true);

            migrationBuilder.CreateIndex(
                name: "IX_Lop_MonHocMamonhoc",
                table: "Lop",
                column: "MonHocMamonhoc");

            migrationBuilder.AddForeignKey(
                name: "FK_Lop_MonHoc_MonHocMamonhoc",
                table: "Lop",
                column: "MonHocMamonhoc",
                principalTable: "MonHoc",
                principalColumn: "mamonhoc");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropForeignKey(
                name: "FK_Lop_MonHoc_MonHocMamonhoc",
                table: "Lop");

            migrationBuilder.DropIndex(
                name: "IX_Lop_MonHocMamonhoc",
                table: "Lop");

            migrationBuilder.DropColumn(
                name: "MonHocMamonhoc",
                table: "Lop");

            migrationBuilder.AddColumn<int>(
                name: "mamonhoc",
                table: "Lop",
                type: "int",
                nullable: false,
                defaultValue: 0);

            migrationBuilder.CreateIndex(
                name: "IX_Lop_mamonhoc",
                table: "Lop",
                column: "mamonhoc");

            migrationBuilder.AddForeignKey(
                name: "FK__Nhom__mamonhoc__0E6E26BF",
                table: "Lop",
                column: "mamonhoc",
                principalTable: "MonHoc",
                principalColumn: "mamonhoc");
        }
    }
}
