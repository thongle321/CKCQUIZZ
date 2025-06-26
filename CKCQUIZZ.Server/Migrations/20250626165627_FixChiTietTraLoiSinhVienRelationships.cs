using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace CKCQUIZZ.Server.Migrations
{
    /// <inheritdoc />
    public partial class FixChiTietTraLoiSinhVienRelationships : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<DateTime>(
                name: "thoigiantraloi",
                table: "ChiTietTraLoiSinhVien",
                type: "datetime2",
                nullable: true);

            migrationBuilder.AlterColumn<string>(
                name: "hinhanhurl",
                table: "CauHoi",
                type: "nvarchar(max)",
                nullable: true,
                oldClrType: typeof(string),
                oldType: "nvarchar(500)",
                oldMaxLength: 500,
                oldNullable: true);

            migrationBuilder.CreateIndex(
                name: "IX_ChiTietTraLoiSinhVien_macauhoi",
                table: "ChiTietTraLoiSinhVien",
                column: "macauhoi");

            migrationBuilder.AddForeignKey(
                name: "FK_ChiTietTraLoiSinhVien_CauHoi",
                table: "ChiTietTraLoiSinhVien",
                column: "macauhoi",
                principalTable: "CauHoi",
                principalColumn: "macauhoi");

            migrationBuilder.AddForeignKey(
                name: "FK_ChiTietTraLoiSinhVien_KetQua_Makq",
                table: "ChiTietTraLoiSinhVien",
                column: "makq",
                principalTable: "KetQua",
                principalColumn: "makq");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropForeignKey(
                name: "FK_ChiTietTraLoiSinhVien_CauHoi",
                table: "ChiTietTraLoiSinhVien");

            migrationBuilder.DropForeignKey(
                name: "FK_ChiTietTraLoiSinhVien_KetQua_Makq",
                table: "ChiTietTraLoiSinhVien");

            migrationBuilder.DropIndex(
                name: "IX_ChiTietTraLoiSinhVien_macauhoi",
                table: "ChiTietTraLoiSinhVien");

            migrationBuilder.DropColumn(
                name: "thoigiantraloi",
                table: "ChiTietTraLoiSinhVien");

            migrationBuilder.AlterColumn<string>(
                name: "hinhanhurl",
                table: "CauHoi",
                type: "nvarchar(500)",
                maxLength: 500,
                nullable: true,
                oldClrType: typeof(string),
                oldType: "nvarchar(max)",
                oldNullable: true);
        }
    }
}
