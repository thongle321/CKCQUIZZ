using CKCQUIZZ.Server.Data;
using CKCQUIZZ.Server.Interfaces;
using CKCQUIZZ.Server.Mappers;
using CKCQUIZZ.Server.Models;
using CKCQUIZZ.Server.Viewmodels.CauHoi;
using CKCQUIZZ.Server.Viewmodels.MonHoc;
using DocumentFormat.OpenXml.Packaging;
using Microsoft.AspNetCore.Hosting;
using Microsoft.EntityFrameworkCore;
using System.IO.Compression;
using System.Text.RegularExpressions;

namespace CKCQUIZZ.Server.Services
{
    public class CauHoiService : ICauHoiService
    {
        private readonly CkcquizzContext _context;
        private readonly IWebHostEnvironment _webHostEnvironment;
        public CauHoiService(CkcquizzContext context, IWebHostEnvironment webHostEnvironment) { _context = context; _webHostEnvironment = webHostEnvironment; }

        public async Task<PagedResult<CauHoiDto>> GetAllPagingAsync(QueryCauHoiDto query)
        {
            var queryable = _context.CauHois.Where(q => q.Trangthai == true).Include(q => q.MamonhocNavigation).Include(q => q.MachuongNavigation).AsQueryable();
            if (query.MaMonHoc.HasValue) queryable = queryable.Where(q => q.Mamonhoc == query.MaMonHoc.Value);
            if (query.MaChuong.HasValue) queryable = queryable.Where(q => q.Machuong == query.MaChuong.Value);
            if (query.DoKho.HasValue) queryable = queryable.Where(q => q.Dokho == query.DoKho.Value);
            if (!string.IsNullOrEmpty(query.Keyword))
            {
                var keywordLower = query.Keyword.ToLower();
                queryable = queryable.Where(q =>
                    q.Noidung.ToLower().Contains(keywordLower) ||
                    (q.MamonhocNavigation != null && q.MamonhocNavigation.Tenmonhoc.ToLower().Contains(keywordLower))
                );
            }


            var totalCount = await queryable.CountAsync();
            var pagedData = await queryable.Skip((query.PageNumber - 1) * query.PageSize).Take(query.PageSize).ToListAsync();
            var dtos = pagedData.Select(p => p.ToCauHoiDto()).ToList();
            return new PagedResult<CauHoiDto> { Items = dtos, TotalCount = totalCount, PageNumber = query.PageNumber, PageSize = query.PageSize };
        }

        public async Task<CauHoiDetailDto?> GetByIdAsync(int id)
        {
            var cauHoi = await _context.CauHois.Include(q => q.MamonhocNavigation).Include(q => q.MachuongNavigation).Include(q => q.CauTraLois).FirstOrDefaultAsync(q => q.Macauhoi == id);
            return cauHoi == null ? null : cauHoi.ToCauHoiDetailDto();
        }

        public async Task<int> CreateAsync(CreateCauHoiRequestDto request, string userId)
        {
            var newCauHoi = new CauHoi { Noidung = request.Noidung, Dokho = request.Dokho, Mamonhoc = request.Mamonhoc, 
                Machuong = request.Machuong, Daodapan = request.Daodapan,
                Nguoitao = userId, Trangthai = true ,Loaicauhoi=request.Loaicauhoi,Hinhanhurl=request.Hinhanhurl};
            foreach (var ctlDto in request.CauTraLois) { newCauHoi.CauTraLois.Add(new CauTraLoi { Noidungtl = ctlDto.Noidungtl, Dapan = ctlDto.Dapan }); }
            _context.CauHois.Add(newCauHoi);
            await _context.SaveChangesAsync();
            return newCauHoi.Macauhoi;
        }
        public async Task<List<CauHoiDetailDto>> GetByMaMonHocAsync(int maMonHoc)
        {
            if (maMonHoc <= 0)
            {
                return new List<CauHoiDetailDto>();
            }
            var cauHois = await _context.CauHois
       .Where(q => q.Mamonhoc == maMonHoc && q.Trangthai == true)
       .Include(q => q.MamonhocNavigation)
       .Include(q => q.MachuongNavigation)
       .Include(q => q.CauTraLois) // Bắt buộc phải Include đáp án
       .OrderBy(q => q.Macauhoi)
       .ToListAsync();
            var dtos = cauHois.Select(ch => ch.ToCauHoiDetailDto()).ToList();

            return dtos;
        }
        public async Task<bool> UpdateAsync(int id, UpdateCauHoiRequestDto request)
        {
            var cauHoi = await _context.CauHois.Include(q => q.CauTraLois).FirstOrDefaultAsync(q => q.Macauhoi == id);
            if (cauHoi == null) return false;
            cauHoi.Noidung = request.Noidung; cauHoi.Dokho = request.Dokho;cauHoi.Mamonhoc=request.MaMonHoc ;
            cauHoi.Machuong = request.Machuong; cauHoi.Daodapan = request.Daodapan; cauHoi.Trangthai = request.Trangthai;cauHoi.Loaicauhoi = request.Loaicauhoi;
            cauHoi.Hinhanhurl = request.Hinhanhurl;
            var dtoCtlIds = request.CauTraLois.Select(c => c.Macautl).ToList();
            var ctlToRemove = cauHoi.CauTraLois.Where(c => !dtoCtlIds.Contains(c.Macautl)).ToList();
            _context.CauTraLois.RemoveRange(ctlToRemove);
            foreach (var ctlDto in request.CauTraLois)
            {
                var existingCtl = cauHoi.CauTraLois.FirstOrDefault(c => c.Macautl == ctlDto.Macautl);
                if (existingCtl != null) { existingCtl.Noidungtl = ctlDto.Noidungtl; existingCtl.Dapan = ctlDto.Dapan; }
                else { cauHoi.CauTraLois.Add(new CauTraLoi { Noidungtl = ctlDto.Noidungtl, Dapan = ctlDto.Dapan }); }
            }
            return await _context.SaveChangesAsync() > 0;
        }
        public async Task<bool> DeleteAsync(int id)
        {
            var cauHoi = await _context.CauHois.FindAsync(id);

            if (cauHoi == null)
            {
                return false; // Không tìm thấy để xóa
            }

            // Đây là Soft Delete!
            cauHoi.Trangthai = false;
            _context.Entry(cauHoi).State = EntityState.Modified;

            return await _context.SaveChangesAsync() > 0;
        }
        public async Task<PagedResult<CauHoiDto>> GetQuestionsForAssignedSubjectsAsync(string userId, QueryCauHoiDto query)
        {
            // 1. Lấy danh sách mã môn học mà người dùng được phân công
            var assignedSubjectIds = await _context.PhanCongs
                .Where(pc => pc.Manguoidung == userId)
                .Select(pc => pc.Mamonhoc)
                .Distinct()
                .ToListAsync();

            // Nếu không được phân công môn nào, trả về kết quả rỗng
            if (!assignedSubjectIds.Any())
            {
                return new PagedResult<CauHoiDto> { Items = new List<CauHoiDto>() };
            }

            // 2. Bắt đầu xây dựng câu truy vấn câu hỏi
            var queryable = _context.CauHois
                .Where(q => q.Trangthai == true && assignedSubjectIds.Contains(q.Mamonhoc)) // Lọc theo các môn được phân công
                .Include(q => q.MamonhocNavigation)
                .Include(q => q.MachuongNavigation)
                .AsQueryable();

            // 3. Áp dụng các bộ lọc từ client (giống hệt hàm GetAllPagingAsync)
            if (query.MaMonHoc.HasValue)
            {
                // Đảm bảo người dùng không "hack" để xem môn họ không được phân công
                if (assignedSubjectIds.Contains(query.MaMonHoc.Value))
                {
                    queryable = queryable.Where(q => q.Mamonhoc == query.MaMonHoc.Value);
                }
            }
            if (query.MaChuong.HasValue) queryable = queryable.Where(q => q.Machuong == query.MaChuong.Value);
            if (query.DoKho.HasValue) queryable = queryable.Where(q => q.Dokho == query.DoKho.Value);
            if (!string.IsNullOrEmpty(query.Keyword))
            {
                var keywordLower = query.Keyword.ToLower();
                queryable = queryable.Where(q =>
                    q.Noidung.ToLower().Contains(keywordLower) ||
                    (q.MamonhocNavigation != null && q.MamonhocNavigation.Tenmonhoc.ToLower().Contains(keywordLower))
                );
            }

            // 4. Phân trang và trả về kết quả
            var totalCount = await queryable.CountAsync();
            var pagedData = await queryable
                .OrderBy(q => q.Macauhoi)
                .Skip((query.PageNumber - 1) * query.PageSize)
                .Take(query.PageSize)
                .ToListAsync();

            var dtos = pagedData.Select(p => p.ToCauHoiDto()).ToList();
            return new PagedResult<CauHoiDto> { Items = dtos, TotalCount = totalCount, PageNumber = query.PageNumber, PageSize = query.PageSize };
        }

        /// <summary>
        /// Lấy câu hỏi do chính giảng viên tạo (chỉ câu hỏi của mình)
        /// </summary>
        public async Task<PagedResult<CauHoiDto>> GetMyCreatedQuestionsAsync(string userId, QueryCauHoiDto query)
        {
            // 1. Lấy danh sách mã môn học mà người dùng được phân công
            var assignedSubjectIds = await _context.PhanCongs
                .Where(pc => pc.Manguoidung == userId)
                .Select(pc => pc.Mamonhoc)
                .Distinct()
                .ToListAsync();

            // Nếu không được phân công môn nào, trả về kết quả rỗng
            if (!assignedSubjectIds.Any())
            {
                return new PagedResult<CauHoiDto> { Items = new List<CauHoiDto>() };
            }

            // 2. Bắt đầu xây dựng câu truy vấn câu hỏi
            // SỬA: Thêm filter theo người tạo (nguoitao)
            var queryable = _context.CauHois
                .Where(q => q.Trangthai == true &&
                           assignedSubjectIds.Contains(q.Mamonhoc) &&
                           q.Nguoitao == userId) // Chỉ lấy câu hỏi do chính mình tạo
                .Include(q => q.MamonhocNavigation)
                .Include(q => q.MachuongNavigation)
                .AsQueryable();

            // 3. Áp dụng các bộ lọc từ query
            if (query.MaMonHoc.HasValue)
            {
                queryable = queryable.Where(q => q.Mamonhoc == query.MaMonHoc.Value);
            }

            if (query.MaChuong.HasValue)
            {
                queryable = queryable.Where(q => q.Machuong == query.MaChuong.Value);
            }

            if (query.DoKho.HasValue)
            {
                queryable = queryable.Where(q => q.Dokho == query.DoKho.Value);
            }

            if (!string.IsNullOrEmpty(query.Keyword))
            {
                var keywordLower = query.Keyword.ToLower();
                queryable = queryable.Where(q =>
                    q.Noidung.ToLower().Contains(keywordLower) ||
                    (q.MamonhocNavigation != null && q.MamonhocNavigation.Tenmonhoc.ToLower().Contains(keywordLower))
                );
            }

            // 4. Phân trang và trả về kết quả
            var totalCount = await queryable.CountAsync();
            var pagedData = await queryable
                .OrderBy(q => q.Macauhoi)
                .Skip((query.PageNumber - 1) * query.PageSize)
                .Take(query.PageSize)
                .ToListAsync();

            var dtos = pagedData.Select(p => p.ToCauHoiDto()).ToList();
            return new PagedResult<CauHoiDto> { Items = dtos, TotalCount = totalCount, PageNumber = query.PageNumber, PageSize = query.PageSize };
        //CODE CHO CHỨC NĂNG IMPORT
        public async Task<KetQuaImportViewModel> ImportFromZipAsync(IFormFile file, int maMonHoc, int maChuong, int doKho, string userId)
        {
            var tempPath = Path.Combine(Path.GetTempPath(), Guid.NewGuid().ToString());
            Directory.CreateDirectory(tempPath);
            try
            {
                var docxFilePath = UnzipAndFindDocx(file, tempPath);
                var parsedQuestions = ParseWordDocument(docxFilePath);

                if (!parsedQuestions.Any())
                {
                    return new KetQuaImportViewModel { ThongBao = "Không tìm thấy câu hỏi hợp lệ nào trong file Word." };
                }

                return await SaveQuestionsToDbAsync(parsedQuestions, tempPath, maMonHoc, maChuong, doKho, userId);
            }
            catch (Exception ex)
            {
                return new KetQuaImportViewModel { DanhSachLoi = new List<string> { $"Lỗi hệ thống không xác định: {ex.Message}" } };
            }
            finally
            {
                if (Directory.Exists(tempPath)) Directory.Delete(tempPath, true);
            }
        }

        // Giải nén file
        private string UnzipAndFindDocx(IFormFile file, string tempPath)
        {
            using (var zipArchive = new ZipArchive(file.OpenReadStream(), ZipArchiveMode.Read))
            {
                zipArchive.ExtractToDirectory(tempPath);
            }
            var docxFiles = Directory.GetFiles(tempPath, "*.docx", SearchOption.AllDirectories);
            if (docxFiles.Length == 0) throw new Exception("Không tìm thấy file .docx trong file .zip.");
            if (docxFiles.Length > 1) throw new Exception("File .zip chỉ được phép chứa một file .docx duy nhất.");
            return docxFiles[0];
        }

        // HÀM Phân tích nội dung file Word
        private List<CauHoiImportData> ParseWordDocument(string filePath)
        {
            var questions = new List<CauHoiImportData>();
            var imageRegex = new Regex(@"\[HINHANH:\s*(?<filename>.*?)\s*\]", RegexOptions.IgnoreCase);
            var goiyRegex = new Regex(@"\[GOIY:\s*(?<content>.*?)\s*\]", RegexOptions.IgnoreCase);
            var dokhoRegex = new Regex(@"\[DOKHO:\s*(?<value>.*?)\s*\]", RegexOptions.IgnoreCase);

            using (var wordDoc = WordprocessingDocument.Open(filePath, false))
            {
                var body = wordDoc.MainDocumentPart.Document.Body;
                var currentBlock = new List<string>();

                // Duyệt qua từng paragraph (đoạn văn) trong file Word
                foreach (var para in body.Elements<DocumentFormat.OpenXml.Wordprocessing.Paragraph>())
                {
                    var text = para.InnerText.Trim();

                    // Nếu gặp một paragraph trống, đó là dấu hiệu kết thúc một khối câu hỏi
                    if (string.IsNullOrWhiteSpace(text) && currentBlock.Any())
                    {
                        // Xử lý khối câu hỏi đã thu thập được
                        ProcessQuestionBlock(currentBlock, questions, imageRegex, goiyRegex, dokhoRegex);

                        // Bắt đầu một khối mới
                        currentBlock.Clear();
                    }
                    else if (!string.IsNullOrWhiteSpace(text))
                    {
                        // Thêm dòng có nội dung vào khối hiện tại
                        currentBlock.Add(text);
                    }
                }

                if (currentBlock.Any())
                {
                    ProcessQuestionBlock(currentBlock, questions, imageRegex, goiyRegex, dokhoRegex);
                }
            }
            return questions;
        }
        private void ProcessQuestionBlock(List<string> blockLines, List<CauHoiImportData> questions, Regex imageRegex, Regex goiyRegex, Regex dokhoRegex)
        {
            // Bỏ qua các dòng không liên quan như [BẮT ĐẦU FILE]
            var relevantLines = blockLines.Where(l => !l.StartsWith("[BẮT ĐẦU FILE]") && !l.StartsWith("[KẾT THÚC FILE]")).ToList();
            if (!relevantLines.Any()) return;

            var currentQuestion = new CauHoiImportData();
            var contentLines = new List<string>();

            foreach (var line in relevantLines)
            {
                if (Regex.IsMatch(line, @"^[A-Z]\.\s", RegexOptions.IgnoreCase))
                {
                    bool isCorrect = line.EndsWith("*");
                    string answerText = isCorrect ? line.Substring(0, line.Length - 1).Trim() : line;
                    answerText = Regex.Replace(answerText, @"^[A-Z]\.\s", "").Trim();
                    currentQuestion.CacLuaChon.Add(new CauTraLoiImportData { NoiDung = answerText, LaDapAnDung = isCorrect });
                }
                else
                {
                    contentLines.Add(line);
                }
            }

            string questionContent = string.Join(" ", contentLines);

            var imageMatch = imageRegex.Match(questionContent);
            if (imageMatch.Success) { currentQuestion.TenFileAnh = imageMatch.Groups["filename"].Value.Trim(); questionContent = imageRegex.Replace(questionContent, "").Trim(); }

            var goiyMatch = goiyRegex.Match(questionContent);
            if (goiyMatch.Success) { currentQuestion.NoiDungGoiY = goiyMatch.Groups["content"].Value.Trim(); questionContent = goiyRegex.Replace(questionContent, "").Trim(); }

            var dokhoMatch = dokhoRegex.Match(questionContent);
            if (dokhoMatch.Success) { currentQuestion.DoKho = MapDoKho(dokhoMatch.Groups["value"].Value.Trim()); questionContent = dokhoRegex.Replace(questionContent, "").Trim(); }

            currentQuestion.NoiDung = questionContent.Trim();

            if (string.IsNullOrWhiteSpace(currentQuestion.NoiDung) && string.IsNullOrEmpty(currentQuestion.TenFileAnh)) return;

            currentQuestion.LoaiCauHoi = currentQuestion.CacLuaChon.Any() ? (currentQuestion.CacLuaChon.Count(a => a.LaDapAnDung) > 1 ? "multiple_choice" : "single_choice") : "essay";

            questions.Add(currentQuestion);
        }
        // HÀM HELPER 3: Chuyển đổi độ khó
        private int? MapDoKho(string value)
        {
            if (int.TryParse(value, out int dokho) && dokho >= 1 && dokho <= 3)
            {
                return dokho;
            }
            return null;
        }

        // HÀM HELPER 4: Lưu file ảnh vào wwwroot/uploads
        private async Task<string> UploadFileAsync(string imagePathInTemp, string originalFileName)
        {
            var uploadsFolderPath = Path.Combine(_webHostEnvironment.WebRootPath, "uploads");
            if (!Directory.Exists(uploadsFolderPath))
            {
                Directory.CreateDirectory(uploadsFolderPath);
            }
            var uniqueFileName = $"{Guid.NewGuid()}_{originalFileName}";
            var destinationPath = Path.Combine(uploadsFolderPath, uniqueFileName);

            using (var sourceStream = new FileStream(imagePathInTemp, FileMode.Open))
            using (var destinationStream = new FileStream(destinationPath, FileMode.Create))
            {
                await sourceStream.CopyToAsync(destinationStream);
            }
            return $"/uploads/{uniqueFileName}";
        }


        // HÀM HELPER 5: Lưu tất cả vào CSDL
        private async Task<KetQuaImportViewModel> SaveQuestionsToDbAsync(List<CauHoiImportData> questions, string tempPath, int maMonHoc, int maChuong, int doKho, string userId)
        {
            var result = new KetQuaImportViewModel { TongSoLuong = questions.Count };
            var newQuestionsToSave = new List<CauHoi>();

            using (var transaction = await _context.Database.BeginTransactionAsync())
            {
                
                foreach (var qDto in questions)
                {
                    try
                    {
                        string imageUrl = null;
                        if (!string.IsNullOrEmpty(qDto.TenFileAnh))
                        {
                            var imagePathInTemp = Directory.GetFiles(tempPath, qDto.TenFileAnh, SearchOption.AllDirectories).FirstOrDefault();
                            if (imagePathInTemp == null) throw new FileNotFoundException($"Không tìm thấy file ảnh '{qDto.TenFileAnh}' trong file .zip.");
                            imageUrl = await UploadFileAsync(imagePathInTemp, qDto.TenFileAnh);
                        }

                        var newQuestion = new CauHoi
                        {
                            Noidung = qDto.NoiDung,
                            Dokho = qDto.DoKho ?? doKho,
                            Loaicauhoi = qDto.LoaiCauHoi,
                            Mamonhoc = maMonHoc,
                            Machuong = maChuong,
                            Hinhanhurl = imageUrl,
                            Nguoitao = userId,
                            Trangthai = true,
                            Daodapan = false,
                            CauTraLois = new List<CauTraLoi>()
                        };

                        if (qDto.LoaiCauHoi == "essay")
                        {
                            if (!string.IsNullOrWhiteSpace(qDto.NoiDungGoiY))
                                newQuestion.CauTraLois.Add(new CauTraLoi { Noidungtl = qDto.NoiDungGoiY, Dapan = true });
                        }
                        else
                        {
                            if (!qDto.CacLuaChon.Any(a => a.LaDapAnDung)) throw new Exception("Câu hỏi trắc nghiệm phải có ít nhất một đáp án đúng.");
                            foreach (var ansDto in qDto.CacLuaChon)
                                newQuestion.CauTraLois.Add(new CauTraLoi { Noidungtl = ansDto.NoiDung, Dapan = ansDto.LaDapAnDung });
                        }
                        newQuestionsToSave.Add(newQuestion);
                    }
                    catch (Exception ex)
                    {
                        result.DanhSachLoi.Add($"Lỗi câu hỏi '{qDto.NoiDung?.Substring(0, Math.Min(qDto.NoiDung?.Length ?? 0, 30))}...': {ex.Message}");
                    }
                }

                
                if (result.DanhSachLoi.Any())
                {
                    await transaction.RollbackAsync();
                    result.ThongBao = "Quá trình Import thất bại do lỗi dữ liệu đầu vào.";
                    return result;
                }
                await _context.CauHois.AddRangeAsync(newQuestionsToSave);

                try
                {
                    await _context.SaveChangesAsync();
                }
                catch (DbUpdateException dbEx)
                {

                    var innerExceptionMessage = dbEx.InnerException?.Message ?? dbEx.Message;

                    result.DanhSachLoi.Add("Lỗi CSDL: " + innerExceptionMessage);
                    result.ThongBao = "Không thể lưu dữ liệu vào cơ sở dữ liệu.";
                    await transaction.RollbackAsync();
                    return result;
                }

                // Nếu mọi thứ thành công
                await transaction.CommitAsync();

                result.SoLuongThanhCong = newQuestionsToSave.Count;
                result.ThongBao = $"Import thành công {result.SoLuongThanhCong}/{result.TongSoLuong} câu hỏi.";
                return result;
            }
        }
    }
}