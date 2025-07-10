using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace CKCQUIZZ.Server.Migrations
{
    /// <inheritdoc />
    public partial class Thêmcộthienthinguoidung : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<bool>(
                name: "hienthi",
                table: "NguoiDung",
                type: "bit",
                nullable: true,
                defaultValue: true);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropColumn(
                name: "hienthi",
                table: "NguoiDung");
        }
    }
}
