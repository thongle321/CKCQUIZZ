using CKCQUIZZ.Server.Interfaces;
using CKCQUIZZ.Server.Viewmodels.CauHoi;
using System.Text.RegularExpressions;
using DocumentFormat.OpenXml.Packaging;
using CKCQUIZZ.Server.Models;
using Microsoft.EntityFrameworkCore;
using System.IO.Compression;

namespace CKCQUIZZ.Server.Services
{
    public class FileService(IWebHostEnvironment _webHostEnvironment, CkcquizzContext _context, IHttpContextAccessor _httpContextAccessor) : IFileService
    {
        public async Task<string> UploadImageAsync(IFormFile file, string subfolder)
        {
            if (file == null || file.Length == 0)
            {
                throw new ArgumentException("Không có file nào được tải lên.");
            }
            if (file.Length > 5 * 1024 * 1024) // 5 MB
            {
                throw new ArgumentException("Kích thước file không được vượt quá 5MB.");
            }
            var allowedExtensions = new[] { ".jpg", ".jpeg", ".png", ".gif" };
            var extension = Path.GetExtension(file.FileName).ToLowerInvariant();
            if (string.IsNullOrEmpty(extension) || !allowedExtensions.Contains(extension))
            {
                throw new ArgumentException("Định dạng file không hợp lệ. Chỉ chấp nhận .jpg, .jpeg, .png, .gif.");
            }

            var uploadPath = Path.Combine(_webHostEnvironment.WebRootPath, "uploads", subfolder);
            if (!Directory.Exists(uploadPath))
            {
                Directory.CreateDirectory(uploadPath);
            }

            var uniqueFileName = Guid.NewGuid().ToString() + "_" + file.FileName;
            var filePath = Path.Combine(uploadPath, uniqueFileName);

            using (var stream = new FileStream(filePath, FileMode.Create))
            {
                await file.CopyToAsync(stream);
            }
            var httpContext = _httpContextAccessor.HttpContext ?? throw new InvalidOperationException("HttpContext là null");
            var request = httpContext.Request;
            return $"{request.Scheme}://{request.Host}/uploads/{subfolder}/{uniqueFileName}";
        }

        public async Task<KetQuaImportViewModel> ImportFromZipAsync(IFormFile file, int maMonHoc, int maChuong, int doKho, string userId)
        {
            var tempPath = Path.Combine(Path.GetTempPath(), Guid.NewGuid().ToString());
            Directory.CreateDirectory(tempPath);
            try
            {
                var docxFilePath = UnzipAndFindDocx(file, tempPath);
                var parsedQuestions = ParseWordDocument(docxFilePath);

                if (parsedQuestions.Count == 0)
                {
                    return new KetQuaImportViewModel { ThongBao = "Không tìm thấy câu hỏi hợp lệ nào trong file Word." };
                }

                return await SaveQuestionsToDbAsync(parsedQuestions, tempPath, maMonHoc, maChuong, doKho, userId);
            }
            catch (Exception ex)
            {
                return new KetQuaImportViewModel { DanhSachLoi = [$"Lỗi hệ thống không xác định: {ex.Message}"] };
            }
            finally
            {
                if (Directory.Exists(tempPath)) Directory.Delete(tempPath, true);
            }
        }

        private static string UnzipAndFindDocx(IFormFile file, string tempPath)
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

                foreach (var para in body!.Elements<DocumentFormat.OpenXml.Wordprocessing.Paragraph>())
                {
                    var text = para.InnerText.Trim();

                    if (string.IsNullOrWhiteSpace(text) && currentBlock.Count != 0)
                    {
                        ProcessQuestionBlock(currentBlock, questions, imageRegex, goiyRegex, dokhoRegex);
                        currentBlock.Clear();
                    }
                    else if (!string.IsNullOrWhiteSpace(text))
                    {
                        currentBlock.Add(text);
                    }
                }

                if (currentBlock.Count != 0)
                {
                    ProcessQuestionBlock(currentBlock, questions, imageRegex, goiyRegex, dokhoRegex);
                }
            }
            return questions;
        }

        private void ProcessQuestionBlock(List<string> blockLines, List<CauHoiImportData> questions, Regex imageRegex, Regex goiyRegex, Regex dokhoRegex)
        {
            var relevantLines = blockLines.Where(l => !l.StartsWith("[BẮT ĐẦU FILE]") && !l.StartsWith("[KẾT THÚC FILE]")).ToList();
            if (relevantLines.Count == 0) return;

            var currentQuestion = new CauHoiImportData();
            var contentLines = new List<string>();

            foreach (var line in relevantLines)
            {
                if (Regex.IsMatch(line, @"^[A-Z]\.\s", RegexOptions.IgnoreCase))
                {
                    bool isCorrect = line.EndsWith('*');
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

            currentQuestion.LoaiCauHoi = currentQuestion.CacLuaChon.Count != 0 ? (currentQuestion.CacLuaChon.Count(a => a.LaDapAnDung) > 1 ? "multiple_choice" : "single_choice") : "essay";

            questions.Add(currentQuestion);
        }

        private static int? MapDoKho(string value)
        {
            if (int.TryParse(value, out int dokho) && dokho >= 1 && dokho <= 3)
            {
                return dokho;
            }
            return null;
        }

        private async Task<string> UploadFileAsync(string imagePathInTemp, string originalFileName)
        {
            var uploadsFolderPath = Path.Combine(_webHostEnvironment.WebRootPath, "uploads", "questions");
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
            var httpContext = _httpContextAccessor.HttpContext ?? throw new InvalidOperationException("HttpContext là null");
            var request = httpContext.Request;
            return $"{request.Scheme}://{request.Host}/uploads/questions/{uniqueFileName}";
        }

        private async Task<KetQuaImportViewModel> SaveQuestionsToDbAsync(List<CauHoiImportData> questions, string tempPath, int maMonHoc, int maChuong, int doKho, string userId)
        {
            var result = new KetQuaImportViewModel { TongSoLuong = questions.Count };
            var newQuestionsToSave = new List<CauHoi>();

            using var transaction = await _context.Database.BeginTransactionAsync();
            foreach (var qDto in questions)
            {
                try
                {
                    string? imageUrl = null;
                    if (!string.IsNullOrEmpty(qDto.TenFileAnh))
                    {
                        var imagePathInTemp = Directory.GetFiles(tempPath, qDto.TenFileAnh, SearchOption.AllDirectories).FirstOrDefault() ?? throw new FileNotFoundException($"Không tìm thấy file ảnh '{qDto.TenFileAnh}' trong file .zip.");
                        imageUrl = await UploadFileAsync(imagePathInTemp, qDto.TenFileAnh);
                    }

                    var newQuestion = new CauHoi
                    {
                        Noidung = qDto.NoiDung!,
                        Dokho = qDto.DoKho ?? doKho,
                        Loaicauhoi = qDto.LoaiCauHoi,
                        Mamonhoc = maMonHoc,
                        Machuong = maChuong,
                        Hinhanhurl = imageUrl,
                        Nguoitao = userId,
                        Trangthai = true,
                        Daodapan = false,
                        CauTraLois = []
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

            if (result.DanhSachLoi.Count != 0)
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
            catch (Microsoft.EntityFrameworkCore.DbUpdateException dbEx)
            {
                var innerExceptionMessage = dbEx.InnerException?.Message ?? dbEx.Message;
                result.DanhSachLoi.Add("Lỗi CSDL: " + innerExceptionMessage);
                result.ThongBao = "Không thể lưu dữ liệu vào cơ sở dữ liệu.";
                await transaction.RollbackAsync();
                return result;
            }

            await transaction.CommitAsync();

            result.SoLuongThanhCong = newQuestionsToSave.Count;
            result.ThongBao = $"Import thành công {result.SoLuongThanhCong}/{result.TongSoLuong} câu hỏi.";
            return result;
        }
    }
}