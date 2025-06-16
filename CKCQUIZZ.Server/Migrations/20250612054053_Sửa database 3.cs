using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace CKCQUIZZ.Server.Migrations
{
    /// <inheritdoc />
    public partial class Sửadatabase3 : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropForeignKey(
                name: "FK_ChiTietQuyen_DanhMucCHucNang_chucnang",
                table: "ChiTietQuyen");

            migrationBuilder.DropPrimaryKey(
                name: "PK_DanhMucCHucNang",
                table: "DanhMucCHucNang");

            migrationBuilder.RenameTable(
                name: "DanhMucCHucNang",
                newName: "DanhMucChucNang");

            migrationBuilder.AddPrimaryKey(
                name: "PK_DanhMucChucNang",
                table: "DanhMucChucNang",
                column: "chucnang");

            migrationBuilder.AddForeignKey(
                name: "FK_ChiTietQuyen_DanhMucChucNang_chucnang",
                table: "ChiTietQuyen",
                column: "chucnang",
                principalTable: "DanhMucChucNang",
                principalColumn: "chucnang",
                onDelete: ReferentialAction.Cascade);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropForeignKey(
                name: "FK_ChiTietQuyen_DanhMucChucNang_chucnang",
                table: "ChiTietQuyen");

            migrationBuilder.DropPrimaryKey(
                name: "PK_DanhMucChucNang",
                table: "DanhMucChucNang");

            migrationBuilder.RenameTable(
                name: "DanhMucChucNang",
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
    }
}
