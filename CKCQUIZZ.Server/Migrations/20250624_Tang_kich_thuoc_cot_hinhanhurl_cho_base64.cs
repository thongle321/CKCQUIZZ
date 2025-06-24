using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace CKCQUIZZ.Server.Migrations
{
    /// <inheritdoc />
    public partial class Tang_kich_thuoc_cot_hinhanhurl_cho_base64 : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            // Tăng kích thước cột hinhanhurl từ nvarchar(500) lên nvarchar(max) để lưu base64
            migrationBuilder.AlterColumn<string>(
                name: "hinhanhurl",
                table: "CauHoi",
                type: "nvarchar(max)",
                nullable: true,
                oldClrType: typeof(string),
                oldType: "nvarchar(500)",
                oldMaxLength: 500,
                oldNullable: true);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            // Rollback về nvarchar(500)
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
