using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace CKCQUIZZ.Server.Migrations
{
    /// <inheritdoc />
    public partial class sualạibảngđềthi : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropForeignKey(
                name: "FK_DeThi_Lop_LopMalop",
                table: "DeThi");

            migrationBuilder.DropForeignKey(
                name: "FK_GiaoDeThi_DeThi",
                table: "GiaoDeThi");

            migrationBuilder.DropForeignKey(
                name: "FK_GiaoDeThi_Lop",
                table: "GiaoDeThi");

            migrationBuilder.DropPrimaryKey(
                name: "PK_GiaoDeThi",
                table: "GiaoDeThi");

            migrationBuilder.DropIndex(
                name: "IX_DeThi_LopMalop",
                table: "DeThi");

            migrationBuilder.DropColumn(
                name: "LopMalop",
                table: "DeThi");

            migrationBuilder.AddPrimaryKey(
                name: "PK__GiaoDeTh__59984D6E5E6CD5F1",
                table: "GiaoDeThi",
                columns: new[] { "made", "malop" });

            migrationBuilder.AddForeignKey(
                name: "FK__GiaoDeThi__made__0A9D95DB",
                table: "GiaoDeThi",
                column: "made",
                principalTable: "DeThi",
                principalColumn: "made");

            migrationBuilder.AddForeignKey(
                name: "FK__GiaoDeThi__manho__09A971A2",
                table: "GiaoDeThi",
                column: "malop",
                principalTable: "Lop",
                principalColumn: "malop");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropForeignKey(
                name: "FK__GiaoDeThi__made__0A9D95DB",
                table: "GiaoDeThi");

            migrationBuilder.DropForeignKey(
                name: "FK__GiaoDeThi__manho__09A971A2",
                table: "GiaoDeThi");

            migrationBuilder.DropPrimaryKey(
                name: "PK__GiaoDeTh__59984D6E5E6CD5F1",
                table: "GiaoDeThi");

            migrationBuilder.AddColumn<int>(
                name: "LopMalop",
                table: "DeThi",
                type: "int",
                nullable: true);

            migrationBuilder.AddPrimaryKey(
                name: "PK_GiaoDeThi",
                table: "GiaoDeThi",
                columns: new[] { "made", "malop" });

            migrationBuilder.CreateIndex(
                name: "IX_DeThi_LopMalop",
                table: "DeThi",
                column: "LopMalop");

            migrationBuilder.AddForeignKey(
                name: "FK_DeThi_Lop_LopMalop",
                table: "DeThi",
                column: "LopMalop",
                principalTable: "Lop",
                principalColumn: "malop");

            migrationBuilder.AddForeignKey(
                name: "FK_GiaoDeThi_DeThi",
                table: "GiaoDeThi",
                column: "made",
                principalTable: "DeThi",
                principalColumn: "made");

            migrationBuilder.AddForeignKey(
                name: "FK_GiaoDeThi_Lop",
                table: "GiaoDeThi",
                column: "malop",
                principalTable: "Lop",
                principalColumn: "malop");
        }
    }
}
