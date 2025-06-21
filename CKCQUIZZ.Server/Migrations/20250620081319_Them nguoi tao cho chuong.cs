using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace CKCQUIZZ.Server.Migrations
{
    /// <inheritdoc />
    public partial class Themnguoitaochochuong : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<string>(
                name: "nguoitao",
                table: "Chuong",
                type: "nvarchar(50)",
                maxLength: 50,
                nullable: true);

            migrationBuilder.CreateIndex(
                name: "IX_Chuong_nguoitao",
                table: "Chuong",
                column: "nguoitao");

            migrationBuilder.AddForeignKey(
                name: "FK_Chuong_NguoiDung",
                table: "Chuong",
                column: "nguoitao",
                principalTable: "NguoiDung",
                principalColumn: "id");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropForeignKey(
                name: "FK_Chuong_NguoiDung",
                table: "Chuong");

            migrationBuilder.DropIndex(
                name: "IX_Chuong_nguoitao",
                table: "Chuong");

            migrationBuilder.DropColumn(
                name: "nguoitao",
                table: "Chuong");
        }
    }
}
