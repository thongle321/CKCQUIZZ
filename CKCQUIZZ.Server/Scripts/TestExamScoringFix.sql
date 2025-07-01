-- Test script để verify fix chấm điểm bài thi
-- Chạy script này để kiểm tra xem fix có hoạt động không

-- 1. Tìm các bài thi có vấn đề (cùng đề thi, số câu đúng khác nhau khi không trả lời)
WITH ExamStats AS (
    SELECT 
        kq.Made,
        kq.Socaudung,
        COUNT(*) as SoLuongBaiThi,
        STRING_AGG(CAST(kq.Makq AS VARCHAR), ', ') as DanhSachKetQuaId
    FROM KetQua kq
    WHERE kq.Thoigianlambai IS NOT NULL  -- Chỉ những bài đã submit
    GROUP BY kq.Made, kq.Socaudung
),
ProblematicExams AS (
    SELECT 
        Made,
        COUNT(DISTINCT Socaudung) as SoLuongDiemKhacNhau
    FROM ExamStats
    GROUP BY Made
    HAVING COUNT(DISTINCT Socaudung) > 1  -- Đề thi có nhiều điểm số khác nhau
)
SELECT 
    pe.Made as ExamId,
    pe.SoLuongDiemKhacNhau,
    dt.Tende as TenDeThi,
    es.Socaudung as DiemSo,
    es.SoLuongBaiThi,
    es.DanhSachKetQuaId
FROM ProblematicExams pe
JOIN DeThi dt ON pe.Made = dt.Made
JOIN ExamStats es ON pe.Made = es.Made
ORDER BY pe.Made, es.Socaudung;

-- 2. Kiểm tra chi tiết các bài thi có vấn đề
PRINT '=== CHI TIẾT CÁC BÀI THI CÓ VẤN ĐỀ ===';

SELECT 
    kq.Makq,
    kq.Made,
    kq.Manguoidung,
    kq.Socaudung,
    kq.Diemthi,
    dt.Tende,
    (SELECT COUNT(*) FROM ChiTietDeThi WHERE Made = kq.Made) as TongSoCauHoi,
    (SELECT COUNT(*) FROM ChiTietTraLoiSinhVien WHERE Makq = kq.Makq AND Dapansv = 1) as SoCauDaChon
FROM KetQua kq
JOIN DeThi dt ON kq.Made = dt.Made
WHERE kq.Thoigianlambai IS NOT NULL
  AND kq.Made IN (
    SELECT Made FROM (
        SELECT Made, COUNT(DISTINCT Socaudung) as SoLuongDiemKhacNhau
        FROM KetQua
        WHERE Thoigianlambai IS NOT NULL
        GROUP BY Made
        HAVING COUNT(DISTINCT Socaudung) > 1
    ) sub
  )
ORDER BY kq.Made, kq.Makq;

-- 3. Kiểm tra dữ liệu chi tiết cho single choice questions
PRINT '=== KIỂM TRA SINGLE CHOICE QUESTIONS ===';

SELECT 
    ct.Makq,
    ct.Macauhoi,
    ch.Loaicauhoi,
    COUNT(*) as TongSoLuaChon,
    SUM(CASE WHEN ct.Dapansv = 1 THEN 1 ELSE 0 END) as SoLuaChonDuocChon,
    CASE 
        WHEN ch.Loaicauhoi = 'single_choice' AND SUM(CASE WHEN ct.Dapansv = 1 THEN 1 ELSE 0 END) > 1 
        THEN 'PROBLEM: Multiple selections for single choice'
        WHEN ch.Loaicauhoi = 'single_choice' AND SUM(CASE WHEN ct.Dapansv = 1 THEN 1 ELSE 0 END) = 0 
        THEN 'OK: No selection'
        WHEN ch.Loaicauhoi = 'single_choice' AND SUM(CASE WHEN ct.Dapansv = 1 THEN 1 ELSE 0 END) = 1 
        THEN 'OK: Single selection'
        ELSE 'OK: Multiple choice or essay'
    END as Status
FROM ChiTietTraLoiSinhVien ct
JOIN CauHoi ch ON ct.Macauhoi = ch.Macauhoi
WHERE ct.Makq IN (
    SELECT kq.Makq FROM KetQua kq
    WHERE kq.Thoigianlambai IS NOT NULL
      AND kq.Made IN (
        SELECT Made FROM (
            SELECT Made, COUNT(DISTINCT Socaudung) as SoLuongDiemKhacNhau
            FROM KetQua
            WHERE Thoigianlambai IS NOT NULL
            GROUP BY Made
            HAVING COUNT(DISTINCT Socaudung) > 1
        ) sub
      )
)
GROUP BY ct.Makq, ct.Macauhoi, ch.Loaicauhoi
HAVING ch.Loaicauhoi = 'single_choice' AND SUM(CASE WHEN ct.Dapansv = 1 THEN 1 ELSE 0 END) > 1
ORDER BY ct.Makq, ct.Macauhoi;

-- 4. Recalculate scores manually để so sánh
PRINT '=== MANUAL SCORE RECALCULATION ===';

WITH ManualScoring AS (
    SELECT 
        ct.Makq,
        ct.Macauhoi,
        ch.Loaicauhoi,
        CASE 
            WHEN ch.Loaicauhoi = 'single_choice' THEN
                CASE WHEN EXISTS (
                    SELECT 1 FROM ChiTietTraLoiSinhVien ct2 
                    JOIN CauTraLoi tl ON ct2.Macautl = tl.Macautl 
                    WHERE ct2.Makq = ct.Makq 
                      AND ct2.Macauhoi = ct.Macauhoi 
                      AND ct2.Dapansv = 1 
                      AND tl.Dapan = 1
                      AND (SELECT COUNT(*) FROM ChiTietTraLoiSinhVien ct3 WHERE ct3.Makq = ct.Makq AND ct3.Macauhoi = ct.Macauhoi AND ct3.Dapansv = 1) = 1
                ) THEN 1 ELSE 0 END
            ELSE 0  -- Simplified for now
        END as IsCorrect
    FROM ChiTietTraLoiSinhVien ct
    JOIN CauHoi ch ON ct.Macauhoi = ch.Macauhoi
    WHERE ct.Makq IN (
        SELECT kq.Makq FROM KetQua kq
        WHERE kq.Thoigianlambai IS NOT NULL
          AND kq.Made IN (
            SELECT Made FROM (
                SELECT Made, COUNT(DISTINCT Socaudung) as SoLuongDiemKhacNhau
                FROM KetQua
                WHERE Thoigianlambai IS NOT NULL
                GROUP BY Made
                HAVING COUNT(DISTINCT Socaudung) > 1
            ) sub
          )
    )
    GROUP BY ct.Makq, ct.Macauhoi, ch.Loaicauhoi
),
RecalculatedScores AS (
    SELECT 
        Makq,
        SUM(IsCorrect) as NewScore
    FROM ManualScoring
    GROUP BY Makq
)
SELECT 
    kq.Makq,
    kq.Socaudung as CurrentScore,
    rs.NewScore as RecalculatedScore,
    CASE WHEN kq.Socaudung != rs.NewScore THEN 'MISMATCH' ELSE 'OK' END as Status
FROM KetQua kq
JOIN RecalculatedScores rs ON kq.Makq = rs.Makq
ORDER BY kq.Makq;
