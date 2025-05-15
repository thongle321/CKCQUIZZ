using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace CKCQUIZZ.Server.Migrations
{
    /// <inheritdoc />
    public partial class RemoveChucNangAndChiTietQuyen : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropTable(
                name: "ChiTietQuyen");

            migrationBuilder.DropTable(
                name: "DanhMucChucNang");

            migrationBuilder.RenameColumn(
                name: "ladapan",
                table: "CauTraLoi",
                newName: "cautl");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.RenameColumn(
                name: "cautl",
                table: "CauTraLoi",
                newName: "ladapan");

            migrationBuilder.CreateTable(
                name: "DanhMucChucNang",
                columns: table => new
                {
                    chucnang = table.Column<string>(type: "nvarchar(50)", maxLength: 50, nullable: false),
                    tenchucnang = table.Column<string>(type: "nvarchar(255)", maxLength: 255, nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK__DanhMucC__83ABCB7C1E105333", x => x.chucnang);
                });

            migrationBuilder.CreateTable(
                name: "ChiTietQuyen",
                columns: table => new
                {
                    manhomquyen = table.Column<int>(type: "int", nullable: false),
                    chucnang = table.Column<string>(type: "nvarchar(50)", maxLength: 50, nullable: false),
                    hanhdong = table.Column<string>(type: "nvarchar(50)", maxLength: 50, nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK__ChiTietQ__881DC49AF31F6AC4", x => new { x.manhomquyen, x.chucnang, x.hanhdong });
                    table.ForeignKey(
                        name: "FK__ChiTietQu__chucn__07C12930",
                        column: x => x.chucnang,
                        principalTable: "DanhMucChucNang",
                        principalColumn: "chucnang");
                    table.ForeignKey(
                        name: "FK__ChiTietQu__manho__06CD04F7",
                        column: x => x.manhomquyen,
                        principalTable: "NhomQuyen",
                        principalColumn: "manhomquyen");
                });

            migrationBuilder.CreateIndex(
                name: "IX_ChiTietQuyen_chucnang",
                table: "ChiTietQuyen",
                column: "chucnang");
        }
    }
}
