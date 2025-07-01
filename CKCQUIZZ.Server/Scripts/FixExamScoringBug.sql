-- Script để kiểm tra và fix bug chấm điểm bài thi
-- Vấn đề: 2 bài thi giống nhau nhưng có số câu đúng khác nhau khi không trả lời

-- 1. Kiểm tra dữ liệu bài thi có vấn đề
SELECT 
    kq.Makq,
    kq.Made,
    kq.Manguoidung,
    kq.Socaudung,
    kq.Diemthi,
    kq.Thoigianlambai,
    dt.Tende
FROM KetQua kq
JOIN DeThi dt ON kq.Made = dt.Made
WHERE kq.Socaudung > 0 AND kq.Thoigianlambai IS NOT NULL
ORDER BY kq.Made, kq.Makq;

-- 2. Kiểm tra chi tiết đáp án của sinh viên cho những bài thi có vấn đề
SELECT 
    ct.Makq,
    ct.Macauhoi,
    ct.Macautl,
    ct.Dapansv,
    ct.Dapantuluansv,
    ch.Loaicauhoi,
    ch.Noidung as CauHoi,
    tl.Noidungtl as DapAn,
    tl.Dapan as LaDapAnDung
FROM ChiTietTraLoiSinhVien ct
JOIN CauHoi ch ON ct.Macauhoi = ch.Macauhoi
JOIN CauTraLoi tl ON ct.Macautl = tl.Macautl
WHERE ct.Makq IN (
    SELECT kq.Makq 
    FROM KetQua kq 
    WHERE kq.Socaudung > 0 AND kq.Thoigianlambai IS NOT NULL
)
ORDER BY ct.Makq, ct.Macauhoi, ct.Macautl;

-- 3. Tìm các trường hợp có Dapansv = 1 nhưng không phải đáp án đúng
SELECT 
    ct.Makq,
    ct.Macauhoi,
    ct.Macautl,
    ct.Dapansv,
    ch.Loaicauhoi,
    tl.Dapan as LaDapAnDung,
    'POTENTIAL_BUG: Student selected wrong answer but Dapansv=1' as Issue
FROM ChiTietTraLoiSinhVien ct
JOIN CauHoi ch ON ct.Macauhoi = ch.Macauhoi
JOIN CauTraLoi tl ON ct.Macautl = tl.Macautl
WHERE ct.Dapansv = 1 
  AND tl.Dapan = 0  -- Sinh viên chọn đáp án sai nhưng Dapansv = 1
  AND ct.Makq IN (
    SELECT kq.Makq 
    FROM KetQua kq 
    WHERE kq.Socaudung > 0 AND kq.Thoigianlambai IS NOT NULL
  );

-- 4. Tìm các trường hợp single choice có nhiều hơn 1 đáp án được chọn
SELECT 
    ct.Makq,
    ct.Macauhoi,
    COUNT(*) as SoLuongDapAnDuocChon,
    'BUG: Multiple answers selected for single choice' as Issue
FROM ChiTietTraLoiSinhVien ct
JOIN CauHoi ch ON ct.Macauhoi = ch.Macauhoi
WHERE ch.Loaicauhoi = 'single_choice'
  AND ct.Dapansv = 1
  AND ct.Makq IN (
    SELECT kq.Makq 
    FROM KetQua kq 
    WHERE kq.Socaudung > 0 AND kq.Thoigianlambai IS NOT NULL
  )
GROUP BY ct.Makq, ct.Macauhoi
HAVING COUNT(*) > 1;

-- 5. Recalculate scores để kiểm tra
WITH CorrectAnswers AS (
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
                ) THEN 1 ELSE 0 END
            WHEN ch.Loaicauhoi = 'multiple_choice' THEN
                CASE WHEN (
                    SELECT COUNT(*) FROM ChiTietTraLoiSinhVien ct2 
                    JOIN CauTraLoi tl ON ct2.Macautl = tl.Macautl 
                    WHERE ct2.Makq = ct.Makq 
                      AND ct2.Macauhoi = ct.Macauhoi 
                      AND ct2.Dapansv = 1 
                      AND tl.Dapan = 1
                ) = (
                    SELECT COUNT(*) FROM CauTraLoi tl 
                    WHERE tl.Macauhoi = ct.Macauhoi AND tl.Dapan = 1
                ) AND (
                    SELECT COUNT(*) FROM ChiTietTraLoiSinhVien ct2 
                    WHERE ct2.Makq = ct.Makq 
                      AND ct2.Macauhoi = ct.Macauhoi 
                      AND ct2.Dapansv = 1
                ) = (
                    SELECT COUNT(*) FROM CauTraLoi tl 
                    WHERE tl.Macauhoi = ct.Macauhoi AND tl.Dapan = 1
                ) THEN 1 ELSE 0 END
            ELSE 0
        END as IsCorrect
    FROM ChiTietTraLoiSinhVien ct
    JOIN CauHoi ch ON ct.Macauhoi = ch.Macauhoi
    WHERE ct.Makq IN (
        SELECT kq.Makq 
        FROM KetQua kq 
        WHERE kq.Socaudung > 0 AND kq.Thoigianlambai IS NOT NULL
    )
    GROUP BY ct.Makq, ct.Macauhoi, ch.Loaicauhoi
),
RecalculatedScores AS (
    SELECT 
        Makq,
        SUM(IsCorrect) as NewSocaudung
    FROM CorrectAnswers
    GROUP BY Makq
)
SELECT 
    kq.Makq,
    kq.Socaudung as CurrentScore,
    rs.NewSocaudung as RecalculatedScore,
    CASE WHEN kq.Socaudung != rs.NewSocaudung THEN 'MISMATCH' ELSE 'OK' END as Status
FROM KetQua kq
JOIN RecalculatedScores rs ON kq.Makq = rs.Makq
WHERE kq.Socaudung > 0 AND kq.Thoigianlambai IS NOT NULL
ORDER BY kq.Makq;
