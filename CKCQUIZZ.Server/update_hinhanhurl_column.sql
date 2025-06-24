-- Tăng kích thước cột hinhanhurl để lưu base64 string
ALTER TABLE CauHoi 
ALTER COLUMN hinhanhurl NVARCHAR(MAX);

-- Kiểm tra kết quả
SELECT 
    COLUMN_NAME,
    DATA_TYPE,
    CHARACTER_MAXIMUM_LENGTH
FROM INFORMATION_SCHEMA.COLUMNS 
WHERE TABLE_NAME = 'CauHoi' 
AND COLUMN_NAME = 'hinhanhurl';
