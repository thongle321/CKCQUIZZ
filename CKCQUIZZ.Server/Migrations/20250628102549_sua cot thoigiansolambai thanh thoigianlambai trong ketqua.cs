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
            migrationBuilder.Sql(@"
            CREATE PROCEDURE CapNhatDapAn
                @MaKQ INT,
                @MaCauHoi INT,
                @MaCauTL INT = NULL, 
                @DapAnSV INT = NULL, 
                @DapAnTuLuanSV NVARCHAR(MAX) = NULL 
            AS
            BEGIN
                SET NOCOUNT ON;

                DECLARE @LoaiCauHoi NVARCHAR(50);

                SELECT @LoaiCauHoi = Loaicauhoi
                FROM CauHoi
                WHERE Macauhoi = @MaCauHoi;

                IF @LoaiCauHoi = 'single_choice'
                BEGIN
                    UPDATE ChiTietTraLoiSinhVien
                    SET Dapansv = 0
                    WHERE MaKQ = @MaKQ AND Macauhoi = @MaCauHoi;

                    IF @MaCauTL IS NOT NULL AND @MaCauTL != 0
                    BEGIN
                        UPDATE ChiTietTraLoiSinhVien
                        SET Dapansv = 1
                        WHERE MaKQ = @MaKQ AND Macauhoi = @MaCauHoi AND Macautl = @MaCauTL;
                    END
                END
                ELSE IF @LoaiCauHoi = 'multiple_choice'
                BEGIN
                    IF @MaCauTL IS NOT NULL
                    BEGIN
                        IF @DapAnSV IS NOT NULL
                        BEGIN
                            UPDATE ChiTietTraLoiSinhVien
                            SET Dapansv = @DapAnSV
                            WHERE MaKQ = @MaKQ AND Macauhoi = @MaCauHoi AND Macautl = @MaCauTL;
                        END
                        ELSE
                        BEGIN
                            UPDATE ChiTietTraLoiSinhVien
                            SET Dapansv = CASE WHEN Dapansv = 1 THEN 0 ELSE 1 END
                            WHERE MaKQ = @MaKQ AND Macauhoi = @MaCauHoi AND Macautl = @MaCauTL;
                        END
                    END
                END
                ELSE IF @LoaiCauHoi = 'essay'
                BEGIN
                    UPDATE ChiTietTraLoiSinhVien
                    SET Dapantuluansv = @DapAnTuLuanSV
                    WHERE MaKQ = @MaKQ AND Macauhoi = @MaCauHoi AND Macautl = @MaCauHoi; -- Assuming Macautl is Macauhoi for essay
                END
            END;
            ");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.Sql("DROP PROCEDURE IF EXISTS CapNhatDapAn;");
            migrationBuilder.RenameColumn(
                name: "thoigianlambai",
                table: "KetQua",
                newName: "thoigiansolambai");
        }
    }
}
