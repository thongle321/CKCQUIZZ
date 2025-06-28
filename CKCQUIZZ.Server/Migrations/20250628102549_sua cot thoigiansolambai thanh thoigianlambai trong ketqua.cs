using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace CKCQUIZZ.Server.Migrations
{
    /// <inheritdoc />
    public partial class suacotthoigiansolambaithanhthoigianlambaitrongketqua : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.RenameColumn(
                name: "thoigiansolambai",
                table: "KetQua",
                newName: "thoigianlambai");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.RenameColumn(
                name: "thoigianlambai",
                table: "KetQua",
                newName: "thoigiansolambai");
        }
    }
}
