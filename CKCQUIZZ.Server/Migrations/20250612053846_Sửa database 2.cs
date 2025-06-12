using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace CKCQUIZZ.Server.Migrations
{
    /// <inheritdoc />
    public partial class Sửadatabase2 : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropForeignKey(
                name: "FK_ChiTietQuyen_danhmucchucnang_chucnang",
                table: "ChiTietQuyen");

            migrationBuilder.DropPrimaryKey(
                name: "PK_danhmucchucnang",
                table: "danhmucchucnang");

            migrationBuilder.RenameTable(
                name: "danhmucchucnang",
                newName: "DanhMucCHucNang");

            migrationBuilder.AddPrimaryKey(
                name: "PK_DanhMucCHucNang",
                table: "DanhMucCHucNang",
                column: "chucnang");

            migrationBuilder.AddForeignKey(
                name: "FK_ChiTietQuyen_DanhMucCHucNang_chucnang",
                table: "ChiTietQuyen",
                column: "chucnang",
                principalTable: "DanhMucCHucNang",
                principalColumn: "chucnang",
                onDelete: ReferentialAction.Cascade);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropForeignKey(
                name: "FK_ChiTietQuyen_DanhMucCHucNang_chucnang",
                table: "ChiTietQuyen");

            migrationBuilder.DropPrimaryKey(
                name: "PK_DanhMucCHucNang",
                table: "DanhMucCHucNang");

            migrationBuilder.RenameTable(
                name: "DanhMucCHucNang",
                newName: "danhmucchucnang");

            migrationBuilder.AddPrimaryKey(
                name: "PK_danhmucchucnang",
                table: "danhmucchucnang",
                column: "chucnang");

            migrationBuilder.AddForeignKey(
                name: "FK_ChiTietQuyen_danhmucchucnang_chucnang",
                table: "ChiTietQuyen",
                column: "chucnang",
                principalTable: "danhmucchucnang",
                principalColumn: "chucnang",
                onDelete: ReferentialAction.Cascade);
        }
    }
}
