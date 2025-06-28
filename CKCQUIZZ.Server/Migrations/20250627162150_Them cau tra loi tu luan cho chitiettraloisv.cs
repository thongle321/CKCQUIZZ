using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace CKCQUIZZ.Server.Migrations
{
    /// <inheritdoc />
    public partial class Themcautraloituluanchochitiettraloisv : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<string>(
                name: "Dapantuluansv",
                table: "ChiTietTraLoiSinhVien",
                type: "nvarchar(max)",
                nullable: true);
            migrationBuilder.Sql(@"
              CREATE OR ALTER PROCEDURE KhoiTaoCauTraLoiSinhVien
                    @MaKQ INT,
                    @MaCauHoi INT
                AS
                BEGIN
                    SET NOCOUNT ON;

                    -- Kiểm tra xem câu hỏi này đã được khởi tạo cho kết quả thi này chưa
                    -- *** CẢI TIẾN 1: Thêm điều kiện này để tránh chèn trùng lặp dữ liệu ***
                    IF NOT EXISTS (SELECT 1 FROM ChiTietTraLoiSinhVien WHERE makq = @MaKQ AND macauhoi = @MaCauHoi)
                    BEGIN
                        DECLARE @LoaiCauHoi NVARCHAR(50);

                        -- Lấy loại câu hỏi
                        SELECT @LoaiCauHoi = CH.Loaicauhoi
                        FROM CauHoi CH
                        WHERE CH.macauhoi = @MaCauHoi;

                        IF @LoaiCauHoi = 'single_choice' OR @LoaiCauHoi = 'multiple_choice'
                        BEGIN
                            -- Chèn các bản ghi cho mỗi lựa chọn đáp án của câu hỏi trắc nghiệm
                            INSERT INTO ChiTietTraLoiSinhVien (makq, macauhoi, macautl, dapansv, Dapantuluansv)
                            SELECT @MaKQ, @MaCauHoi, CTL.Macautl, 0, NULL
                            FROM CauTraLoi CTL
                            WHERE CTL.macauhoi = @MaCauHoi;
                        END
                        ELSE IF @LoaiCauHoi = 'essay'
                        BEGIN
                            -- Chèn 1 bản ghi cho câu hỏi tự luận
                            -- *** CẢI TIẾN 2: Dùng chính @MaCauHoi làm Macautl để dễ tìm kiếm sau này ***
                            INSERT INTO ChiTietTraLoiSinhVien (makq, macauhoi, macautl, dapansv, Dapantuluansv)
                            VALUES (@MaKQ, @MaCauHoi, @MaCauHoi, 0, NULL); -- Thay NULL bằng @MaCauHoi
                        END
                    END
                END;
            ");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.Sql("DROP PROCEDURE IF EXISTS KhoiTaoCauTraLoiSinhVien;");
            migrationBuilder.DropColumn(
                name: "Dapantuluansv",
                table: "ChiTietTraLoiSinhVien");
        }
    }
}
