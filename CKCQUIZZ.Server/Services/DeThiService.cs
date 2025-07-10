using CKCQUIZZ.Server.Data;
using CKCQUIZZ.Server.Interfaces;
using CKCQUIZZ.Server.Models;
using CKCQUIZZ.Server.Viewmodels.DeThi;
using CKCQUIZZ.Server.Viewmodels.Student;
using Microsoft.Data.SqlClient;
using Microsoft.EntityFrameworkCore;
using System.Security.Claims;
using Microsoft.AspNetCore.SignalR;
using CKCQUIZZ.Server.Hubs;


namespace CKCQUIZZ.Server.Services
{
    public class DeThiService(CkcquizzContext _context, IHttpContextAccessor _httpContextAccessor, IHubContext<ExamHub, IExamHubClient> _examHubContext) : IDeThiService
    {
        private static readonly Random random = new();
        private string GetCurrentUserId()
        {
            var userId = _httpContextAccessor.HttpContext?.User?.FindFirstValue(ClaimTypes.NameIdentifier);
            if (string.IsNullOrEmpty(userId))
            {
                throw new UnauthorizedAccessException("Không thể xác định người dùng. Người dùng chưa đăng nhập hoặc token không hợp lệ.");
            }
            return userId;
        }
        public async Task<List<DeThiViewModel>> GetAllAsync()
        {
            var currentUserId = GetCurrentUserId();
            var assignedSubjectIds = await _context.PhanCongs
              .Where(pc => pc.Manguoidung == currentUserId)
              .Select(pc => pc.Mamonhoc)
              .Distinct()
              .ToListAsync();
            if (!assignedSubjectIds.Any())
            {
                return new List<DeThiViewModel>();
            }
            // 2. Lấy tất cả đề thi của các môn học đó
            var deThis = await _context.DeThis
              .Include(d => d.Malops)
              .Where(d => d.Monthi.HasValue && assignedSubjectIds.Contains(d.Monthi.Value))
              .OrderByDescending(d => d.Thoigiantao)
              .ToListAsync();

            var viewModels = deThis.Select(d => new DeThiViewModel
            {
                Made = d.Made,
                Tende = d.Tende,
                Thoigianbatdau = d.Thoigiantbatdau ?? DateTime.MinValue,
                Thoigianketthuc = d.Thoigianketthuc ?? DateTime.MinValue,
                Monthi = d.Monthi ?? 0,
                GiaoCho = d.Malops.Count != 0 ? string.Join(", ", d.Malops.Select(l => $"{l.Tenlop} (NH {l.Namhoc} - HK{l.Hocky})")) : "Chưa giao",
                Trangthai = d.Trangthai ?? false,
                Xemdiemthi = d.Xemdiemthi ?? false,
                Hienthibailam = d.Hienthibailam ?? false,
                Xemdapan = d.Xemdapan ?? false,
                NguoiTao = d.Nguoitao,
                Troncauhoi = d.Troncauhoi ?? false,
                
            }).ToList();

            return viewModels;
        }

        public async Task<DeThiDetailViewModel?> GetByIdAsync(int id)
        {
            var deThi = await _context.DeThis
                .Include(d => d.Malops)
                .Include(d => d.ChiTietDeThis).ThenInclude(ct => ct.MacauhoiNavigation)
                .FirstOrDefaultAsync(d => d.Made == id);

            if (deThi is null) return null;

            return new DeThiDetailViewModel
            {
                Made = deThi.Made,
                Tende = deThi.Tende!,
                Monthi = deThi.Monthi,
                Thoigianthi = deThi.Thoigianthi ?? 0,
                Thoigiantbatdau = deThi.Thoigiantbatdau ?? DateTime.MinValue,
                Thoigianketthuc = deThi.Thoigianketthuc ?? DateTime.MinValue,
                Xemdiemthi = deThi.Xemdiemthi ?? false,
                Hienthibailam = deThi.Hienthibailam ?? false,
                Xemdapan = deThi.Xemdapan ?? false,
                Troncauhoi = deThi.Troncauhoi ?? false,
                Loaide = deThi.Loaide ?? 1,
                Socaude = deThi.Socaude ?? 0,
                Socautb = deThi.Socautb ?? 0,
                Socaukho = deThi.Socaukho ?? 0,
                Malops = deThi.Malops.Select(l => l.Malop).ToList(),
                Machuongs = deThi.ChiTietDeThis.Select(ct => ct.MacauhoiNavigation.Machuong).Distinct().ToList()
            };
        }
        public async Task<TestResultResponseDto?> GetTestResultsAsync(int deThiId)
        {
            var deThi = await _context.DeThis
                .Include(d => d.Malops)
                .FirstOrDefaultAsync(d => d.Made == deThiId);

            if (deThi is null)
            {
                return null;
            }

            string tenMonHoc = "Không xác định";
            if (deThi.Monthi.HasValue)
            {
                var monHoc = await _context.MonHocs.FindAsync(deThi.Monthi.Value);
                if (monHoc != null)
                {
                    tenMonHoc = monHoc.Tenmonhoc;
                }
            }

            var deThiInfo = new TestInfoDto
            {
                Made = deThi.Made,
                Tende = deThi.Tende!,
                TenMonHoc = tenMonHoc
            };
            var assignedLops = deThi.Malops;
            var assignedLopIds = assignedLops.Select(l => l.Malop).ToList();

            var lopsForFilter = assignedLops.Select(l => new LopInfoDto
            {
                Malop = l.Malop,
                Tenlop = l.Tenlop
            }).ToList();

            var allAssignedStudents = await _context.ChiTietLops
                .Where(ctl => assignedLopIds.Contains(ctl.Malop))
                .Include(ctl => ctl.ManguoidungNavigation)
                .Select(ctl => new
                {
                    StudentInfo = ctl.ManguoidungNavigation,
                    LopId = ctl.Malop
                })
                .Distinct()
                .ToListAsync();

            var actualResultsMap = await _context.KetQuas
                .Where(kq => kq.Made == deThiId)
                .ToDictionaryAsync(kq => kq.Manguoidung);

            var studentResults = allAssignedStudents.Select(s =>
            {
                var student = s.StudentInfo;
                string ho = string.Empty;
                string ten = student.Hoten ?? "";
                int lastSpaceIndex = ten.LastIndexOf(' ');
                if (lastSpaceIndex > -1)
                {
                    ho = ten.Substring(0, lastSpaceIndex);
                    ten = ten.Substring(lastSpaceIndex + 1);
                }

                if (actualResultsMap.TryGetValue(student.Id, out var ketQua))
                {
                    bool submitted = ketQua.Thoigianlambai != null;
                    return new StudentResultDto
                    {
                        Mssv = student.Id,
                        Ho = ho,
                        Ten = ten,
                        Diem = ketQua.Diemthi,
                        ThoiGianVaoThi = ketQua.Thoigianvaothi,
                        ThoiGianThi = ketQua.Thoigianlambai,
                        Solanthoat = ketQua.Solanchuyentab ?? 0,
                        Malop = s.LopId,
                        TrangThai = submitted ? "Đã nộp" : "Chưa nộp",
                        KetQuaId = submitted ? ketQua.Makq : null
                    };
                }
                else
                {
                    return new StudentResultDto
                    {
                        Mssv = student.Id,
                        Ho = ho,
                        Ten = ten,
                        Diem = null,
                        ThoiGianVaoThi = null,
                        ThoiGianThi = null,
                        Solanthoat = 0,
                        Malop = s.LopId,
                        TrangThai = "Vắng thi",
                        KetQuaId = null
                    };
                }
            }).ToList();

            return new TestResultResponseDto
            {
                DeThiInfo = deThiInfo,
                Lops = lopsForFilter,
                Results = studentResults
            };
        }
        public async Task<DeThiViewModel> CreateAsync(DeThiCreateRequest request)
        {
            var creatorId = _httpContextAccessor.HttpContext?.User?.FindFirstValue(ClaimTypes.NameIdentifier);
            if (string.IsNullOrEmpty(creatorId))
            {
                throw new UnauthorizedAccessException("Không thể xác định người dùng.");
            }

            var newDeThi = new DeThi
            {
                Tende = request.Tende,
                Thoigiantbatdau = request.Thoigianbatdau.ToUniversalTime(),
                Thoigianketthuc = request.Thoigianketthuc.ToUniversalTime(),
                Thoigianthi = request.Thoigianthi,
                Monthi = request.Monthi,
                Xemdiemthi = request.Xemdiemthi,
                Hienthibailam = request.Hienthibailam,
                Xemdapan = request.Xemdapan,
                Troncauhoi = request.Troncauhoi,
                Loaide = request.Loaide,
                Socaude = request.Socaude,
                Socautb = request.Socautb,
                Socaukho = request.Socaukho,
                Nguoitao = creatorId,
                Thoigiantao = DateTime.UtcNow,
                Trangthai = true
            };

            var selectedLops = await _context.Lops.Where(l => request.Malops.Contains(l.Malop)).ToListAsync();
            newDeThi.Malops = selectedLops;

            if (request.Loaide == 1 && request.Machuongs.Count != 0)
            {
                var cauDe = await GetRandomQuestionsByDifficulty(request.Machuongs, 1, request.Socaude);
                var cauTB = await GetRandomQuestionsByDifficulty(request.Machuongs, 2, request.Socautb);
                var cauKho = await GetRandomQuestionsByDifficulty(request.Machuongs, 3, request.Socaukho);
                int thuTuCounter = 1;
                foreach (var question in cauDe.Concat(cauTB).Concat(cauKho))
                {
                    newDeThi.ChiTietDeThis.Add(new ChiTietDeThi { Macauhoi = question.Macauhoi, Diemcauhoi = 1, Thutu = thuTuCounter++ });
                }
            }

            _context.DeThis.Add(newDeThi);
            await _context.SaveChangesAsync();

            var assignedClassIds = newDeThi.Malops.Select(l => l.Malop).ToList();
            var studentIdsInClasses = await _context.ChiTietLops
                .Where(ctl => assignedClassIds.Contains(ctl.Malop) && ctl.Trangthai == true)
                .Select(ctl => ctl.Manguoidung)
                .Distinct()
                .ToListAsync();

            if (studentIdsInClasses.Count != 0)
            {
                var tenMonHoc = await _context.MonHocs
                    .Where(m => m.Mamonhoc == newDeThi.Monthi)
                    .Select(m => m.Tenmonhoc)
                    .FirstOrDefaultAsync() ?? "Không xác định";

                var now = DateTime.UtcNow;

                var examDtoForStudent = new ExamForClassDto
                {
                    Made = newDeThi.Made,
                    Tende = newDeThi.Tende,
                    TenMonHoc = tenMonHoc,
                    TongSoCau = newDeThi.ChiTietDeThis.Count,
                    Thoigianthi = newDeThi.Thoigianthi ?? 0,
                    Thoigiantbatdau = newDeThi.Thoigiantbatdau.Value,
                    Thoigianketthuc = newDeThi.Thoigianketthuc.Value,
                    TrangthaiThi = (now < newDeThi.Thoigiantbatdau.Value) ? "SapDienRa" :
              (now > newDeThi.Thoigianketthuc.Value) ? "DaKetThuc" : "DangDienRa",
                    KetQuaId = null
                };
                await _examHubContext.Clients.Users(studentIdsInClasses).ReceiveExam(examDtoForStudent);
                await _examHubContext.Clients.Users(studentIdsInClasses).ReceiveExamStatusUpdate(examDtoForStudent.Made, examDtoForStudent.TrangthaiThi);
            }

            return new DeThiViewModel
            {
                Made = newDeThi.Made,
                Tende = newDeThi.Tende,
                Thoigianbatdau = newDeThi.Thoigiantbatdau.Value,
                Thoigianketthuc = newDeThi.Thoigianketthuc.Value,
                GiaoCho = newDeThi.Malops.Count != 0 ? string.Join(", ", newDeThi.Malops.Select(l => l.Tenlop)) : "Chưa giao",
                Trangthai = newDeThi.Trangthai ?? false
            };
        }

        public async Task<bool> UpdateAsync(int id, DeThiUpdateRequest request)
        {
            var currentUserId = GetCurrentUserId();
            var deThi = await _context.DeThis
                .Include(d => d.Malops)
                .FirstOrDefaultAsync(d => d.Made == id);
            if (deThi is null) return false;
            if (deThi.Nguoitao != currentUserId)
            {
                throw new UnauthorizedAccessException("Bạn không có quyền chỉnh sửa đề thi này.");
            }
            deThi.Tende = request.Tende;
            deThi.Thoigiantbatdau = request.Thoigianbatdau.ToUniversalTime();
            deThi.Thoigianketthuc = request.Thoigianketthuc.ToUniversalTime();
            deThi.Xemdiemthi = request.Xemdiemthi;
            deThi.Hienthibailam = request.Hienthibailam;
            deThi.Xemdapan = request.Xemdapan;
            deThi.Troncauhoi = request.Troncauhoi;

            _context.DeThis.Update(deThi);
            await _context.SaveChangesAsync();
            return true;
        }
        public async Task<bool> DeleteAsync(int id)
        {
            var currentUserId = GetCurrentUserId();
            var deThi = await _context.DeThis.FindAsync(id);
            if (deThi is null) return false;
            deThi.Trangthai = false;
            if (deThi.Nguoitao != currentUserId)
            {
                throw new UnauthorizedAccessException("Bạn không có quyền ẩn đề thi này.");
            }
            _context.Entry(deThi).State = EntityState.Modified;

            return await _context.SaveChangesAsync() > 0;
        }
        public async Task<bool> RestoreAsync(int id)
        {
            var currentUserId = GetCurrentUserId();
            var deThi = await _context.DeThis.FindAsync(id);
            if (deThi is null) return false;
            if (deThi.Nguoitao != currentUserId)
            {
                throw new UnauthorizedAccessException("Bạn không có hiển thị đề thi này.");
            }
            deThi.Trangthai = true;
            _context.Entry(deThi).State = EntityState.Modified;

            return await _context.SaveChangesAsync() > 0;
        }
        public async Task<bool> HardDeleteAsync(int id)
        {
            var currentUserId = GetCurrentUserId();
            var deThi = await _context.DeThis
                .Include(d => d.ChiTietDeThis)
                .Include(d => d.Malops)       
                .FirstOrDefaultAsync(d => d.Made == id);

            if (deThi is null)
            {
                return false;
            }
            if (deThi.Nguoitao != currentUserId)
            {
                throw new UnauthorizedAccessException("Bạn không có quyền xóa đề thi này.");
            }
            var hasResults = await _context.KetQuas.AnyAsync(kq => kq.Made == id);

            if (hasResults)
            {
                throw new InvalidOperationException("Không thể xóa đề thi này vì đã có sinh viên làm bài.");
            }
            deThi.Malops.Clear();
            _context.ChiTietDeThis.RemoveRange(deThi.ChiTietDeThis);
            _context.DeThis.Remove(deThi);
            return await _context.SaveChangesAsync() > 0;
        }
        public async Task<bool> CapNhatChiTietDeThiAsync(int maDe, CapNhatChiTietDeThiRequest request)
        {
            var deThi = await _context.DeThis
                .Include(d => d.ChiTietDeThis)
                .FirstOrDefaultAsync(d => d.Made == maDe);

            if (deThi is null)
            {
                return false;
            }

            _context.ChiTietDeThis.RemoveRange(deThi.ChiTietDeThis);

            if (request.MaCauHois != null && request.MaCauHois.Count != 0)
            {
                var newChiTietList = request.MaCauHois.Select((maCauHoi, index) => new ChiTietDeThi
                {
                    Made = maDe,
                    Macauhoi = maCauHoi,
                    Diemcauhoi = 1,
                    Thutu = index + 1
                }).ToList();

                await _context.ChiTietDeThis.AddRangeAsync(newChiTietList);
            }

            return await _context.SaveChangesAsync() > 0;
        }
        private async Task<List<CauHoi>> GetRandomQuestionsByDifficulty(List<int> chuongIds, int doKho, int count)
        {
            if (count <= 0) return [];
            return await _context.CauHois
                .Where(q => chuongIds.Contains(q.Machuong) && q.Dokho == doKho && q.Trangthai == true)
                .OrderBy(q => Guid.NewGuid())
                .Take(count)
                .ToListAsync();
        }
        public async Task<IEnumerable<ExamForClassDto>> GetExamsForClassAsync(int classId, string studentId)
        {
            var now = DateTime.UtcNow;
            var exams = await _context.DeThis
                .Where(d => d.Trangthai == true && d.Malops.Any(l => l.Malop == classId))
                .OrderByDescending(d => d.Thoigiantbatdau)
                .Select(d => new ExamForClassDto
                {
                    Made = d.Made,
                    Tende = d.Tende,
                    TenMonHoc = _context.MonHocs
                                    .Where(m => m.Mamonhoc == d.Monthi)
                                    .Select(m => m.Tenmonhoc)
                                    .FirstOrDefault() ?? "Không xác định",
                    TongSoCau = d.ChiTietDeThis.Count(),
                    Thoigianthi = d.Thoigianthi ?? 0,
                    Thoigiantbatdau = d.Thoigiantbatdau!.Value,
                    Thoigianketthuc = d.Thoigianketthuc!.Value,

                    TrangthaiThi = (now < d.Thoigiantbatdau) ? "SapDienRa" :
                                (now > d.Thoigianketthuc) ? "DaKetThuc" : "DangDienRa",
                    KetQuaId = _context.KetQuas
                                    .Where(kq => kq.Made == d.Made && kq.Manguoidung == studentId && kq.Thoigianlambai != null) // Only show KetQuaId if exam is submitted
                                    .Select(kq => (int?)kq.Makq)
                                    .FirstOrDefault()
                })
                .ToListAsync();

            return exams;
        }
        public async Task<IEnumerable<ExamForClassDto>> GetAllExamsForStudentAsync(string studentId)
        {
            var now = DateTime.UtcNow;
            var studentClassIds = await _context.ChiTietLops
                .Where(ctl => ctl.Manguoidung == studentId && ctl.Trangthai == true)
                .Select(ctl => ctl.Malop)
                .ToListAsync();

            if (!studentClassIds.Any())
            {
                return new List<ExamForClassDto>();
            }

            var exams = await _context.DeThis
                .Where(d => d.Trangthai == true && d.Malops.Any(l => studentClassIds.Contains(l.Malop)))
                .OrderByDescending(d => d.Thoigiantbatdau)
                .Select(d => new ExamForClassDto
                {
                    Made = d.Made,
                    Tende = d.Tende,
                    TenMonHoc = _context.MonHocs
                                    .Where(m => m.Mamonhoc == d.Monthi)
                                    .Select(m => m.Tenmonhoc)
                                    .FirstOrDefault() ?? "Không xác định",
                    TongSoCau = d.ChiTietDeThis.Count(),
                    Thoigianthi = d.Thoigianthi ?? 0,
                    Thoigiantbatdau = d.Thoigiantbatdau!.Value,
                    Thoigianketthuc = d.Thoigianketthuc!.Value,
                    Xemdiemthi = d.Xemdiemthi ?? false,
                    Hienthibailam = d.Hienthibailam ?? false,
                    Xemdapan = d.Xemdapan ?? false,

                    TrangthaiThi = (now < d.Thoigiantbatdau.Value) ? "SapDienRa" :
              (now > d.Thoigianketthuc.Value) ? "DaKetThuc" : "DangDienRa",
                    KetQuaId = _context.KetQuas
                                    .Where(kq => kq.Made == d.Made && kq.Manguoidung == studentId)
                                    .Select(kq => (int?)kq.Makq)
                                    .FirstOrDefault()
                })
                .ToListAsync();

            return exams;
        }
        public async Task<StudentExamDetailDto?> GetExamForStudent(int deThiId, string studentId)
        {
            var deThi = await _context.DeThis
                .Include(d => d.ChiTietDeThis)
                    .ThenInclude(ct => ct.MacauhoiNavigation)
                        .ThenInclude(ch => ch.CauTraLois)
                .FirstOrDefaultAsync(d => d.Made == deThiId && d.Trangthai == true);

            if (deThi is null)
            {
                return null;
            }

            var examDto = new StudentExamDetailDto
            {
                Made = deThi.Made,
                Tende = deThi.Tende!,
                Thoigianthi = deThi.Thoigianthi ?? 0,
            };

            var questions = deThi.ChiTietDeThis.Select(ct => ct.MacauhoiNavigation).ToList();

            if (deThi.Troncauhoi == true)
            {
                var seed = deThi.Made.GetHashCode() + studentId.GetHashCode();
                var seededRandom = new Random(seed);
                questions = questions.OrderBy(q => seededRandom.Next()).ToList();
            }

            foreach (var question in questions)
            {
                var questionDto = new StudentQuestionDto
                {
                    Macauhoi = question.Macauhoi,
                    Noidung = question.Noidung,
                    Loaicauhoi = question.Loaicauhoi,
                    Hinhanhurl = question.Hinhanhurl,
                };


                var answers = question.CauTraLois.ToList();
                if (question.Daodapan == true)
                {
                    var seed = deThi.Made.GetHashCode() + studentId.GetHashCode() + question.Macauhoi;
                    var seededRandom = new Random(seed);
                    answers = answers.OrderBy(a => seededRandom.Next()).ToList();
                }

                foreach (var answer in answers)
                {
                    questionDto.Answers.Add(new StudentAnswerDto
                    {
                        Macautl = answer.Macautl,
                        Noidungtl = answer.Noidungtl,
                    });
                }
                examDto.Questions.Add(questionDto);
            }

            return examDto;
        }
        public async Task<StartExamResponseDto> StartExam(StartExamRequestDto request, string studentId)
        {
            var existingResult = await _context.KetQuas
                  .FirstOrDefaultAsync(kq => kq.Made == request.ExamId && kq.Manguoidung == studentId);

            if (existingResult != null)
            {
                return new StartExamResponseDto
                {
                    KetQuaId = existingResult.Makq,
                    ExamId = existingResult.Made,
                    Thoigianbatdau = existingResult.Thoigianvaothi ?? DateTime.MinValue
                };
            }

            var deThi = await _context.DeThis
                .Include(d => d.ChiTietDeThis)
                .AsNoTracking()
                .FirstOrDefaultAsync(d => d.Made == request.ExamId && d.Trangthai == true);

            if (deThi is null)
            {
                throw new KeyNotFoundException("Không tìm thấy đề thi hoặc đề thi không hoạt động.");
            }


            var newKetQua = new KetQua
            {
                Made = request.ExamId,
                Manguoidung = studentId,
                Thoigianvaothi = DateTime.UtcNow,
                Diemthi = 0,
                Socaudung = 0,
                Thoigianlambai = null
            };
            _context.KetQuas.Add(newKetQua);
            await _context.SaveChangesAsync();

            var chiTietKetQuaList = deThi.ChiTietDeThis.Select(ct => new ChiTietKetQua
            {
                Makq = newKetQua.Makq,
                Macauhoi = ct.Macauhoi,
                Diemketqua = 0
            }).ToList();

            if (chiTietKetQuaList.Count != 0)
            {
                await _context.ChiTietKetQuas.AddRangeAsync(chiTietKetQuaList);

                await _context.SaveChangesAsync();
            }

            foreach (var chiTietDeThi in deThi.ChiTietDeThis)
            {
                try
                {
                    var maKqParam = new SqlParameter("@MaKQ", newKetQua.Makq);
                    var maCauHoiParam = new SqlParameter("@MaCauHoi", chiTietDeThi.Macauhoi);


                    await _context.Database.ExecuteSqlRawAsync(
                        "EXEC dbo.KhoiTaoCauTraLoiSinhVien @MaKQ, @MaCauHoi",
                        maKqParam,
                        maCauHoiParam
                    );
                }
                catch (Exception)
                {
                    throw;
                }
            }


            return new StartExamResponseDto
            {
                KetQuaId = newKetQua.Makq,
                ExamId = newKetQua.Made,
                Thoigianbatdau = newKetQua.Thoigianvaothi ?? DateTime.MinValue
            };
        }

        public async Task<ExamResultDto> SubmitExam(SubmitExamRequestDto submission, string studentId)
        {
            var existingResult = await _context.KetQuas
                .FirstOrDefaultAsync(kq => kq.Makq == submission.KetQuaId && kq.Manguoidung == studentId) ?? throw new KeyNotFoundException("Không tìm thấy kết quả bài thi để nộp.");
            var deThi = await _context.DeThis
                .Include(d => d.ChiTietDeThis)
                    .ThenInclude(ct => ct.MacauhoiNavigation)
                        .ThenInclude(ch => ch.CauTraLois)
                .AsNoTracking()
                .FirstOrDefaultAsync(d => d.Made == existingResult.Made) ?? throw new KeyNotFoundException("Không tìm thấy đề thi liên quan.");


            var correctAnswersLookup = deThi.ChiTietDeThis
                .SelectMany(ct => ct.MacauhoiNavigation.CauTraLois)
                .Where(ans => ans.Dapan == true)
                .ToLookup(ans => ans.Macauhoi, ans => ans);

            var studentAnswers = await _context.ChiTietTraLoiSinhViens
                .Where(ct => ct.Makq == submission.KetQuaId)
                .ToListAsync();
            var chiTietKetQuas = await _context.ChiTietKetQuas
                .Where(ct => ct.Makq == submission.KetQuaId)
                .ToListAsync();

            int soCauDung = 0;
            double tongDiem = 0.0;
            int tongSoCau = deThi.ChiTietDeThis.Count;
            double diemMoiCau = (tongSoCau > 0) ? 10.0 / tongSoCau : 0;

            foreach (var questionDetail in deThi.ChiTietDeThis)
            {
                var question = questionDetail.MacauhoiNavigation;
                int macauhoi = question.Macauhoi;
                double diemCauHoi = 0.0;

                if (question.Loaicauhoi == "single_choice")
                {
                    var correctAnswerId = correctAnswersLookup[macauhoi].FirstOrDefault()?.Macautl;
                    var studentAnswerId = studentAnswers.FirstOrDefault(a => a.Macauhoi == macauhoi && a.Dapansv == 1)?.Macautl;
                    if (correctAnswerId.HasValue && studentAnswerId.HasValue && correctAnswerId == studentAnswerId)
                    {
                        soCauDung++;
                        diemCauHoi = diemMoiCau;
                    }
                }
                else if (question.Loaicauhoi == "multiple_choice")
                {
                    var correctSet = correctAnswersLookup[macauhoi].Select(a => a.Macautl).ToHashSet();
                    var studentSet = studentAnswers.Where(a => a.Macauhoi == macauhoi && a.Dapansv == 1).Select(a => a.Macautl).ToHashSet();
                    if (correctSet.Count != 0 && correctSet.SetEquals(studentSet))
                    {
                        soCauDung++;
                        diemCauHoi = diemMoiCau;

                    }
                }
                else if (question.Loaicauhoi == "essay")
                {
                    var correctAnswerText = correctAnswersLookup[macauhoi].FirstOrDefault()?.Noidungtl;

                    var studentAnswerText = studentAnswers.FirstOrDefault(a => a.Macauhoi == macauhoi)?.Dapantuluansv;

                    if (!string.IsNullOrWhiteSpace(correctAnswerText) && !string.IsNullOrWhiteSpace(studentAnswerText))
                    {
                        if (correctAnswerText.Trim().Equals(studentAnswerText.Trim(), StringComparison.OrdinalIgnoreCase))
                        {
                            soCauDung++;
                            diemCauHoi = diemMoiCau;

                        }
                    }
                }
                var chiTietKetQua = chiTietKetQuas.FirstOrDefault(ct => ct.Macauhoi == macauhoi);

                if (chiTietKetQua != null)
                {
                    chiTietKetQua.Diemketqua = diemCauHoi;
                }
                tongDiem += diemCauHoi;

            }
            tongDiem = Math.Min(tongDiem, 10.0);
            tongDiem = Math.Round(tongDiem, 2);

            existingResult.Diemthi = tongDiem;
            existingResult.Socaudung = soCauDung;
            existingResult.Thoigianlambai = submission.ThoiGianLamBai;

            _context.KetQuas.Update(existingResult);
            await _context.SaveChangesAsync();

            return new ExamResultDto
            {
                KetQuaId = existingResult.Makq,
                DiemThi = existingResult.Diemthi ?? 0,
                SoCauDung = soCauDung,
                TongSoCau = deThi.ChiTietDeThis.Count
            };
        }
        public async Task<ExamReviewDto?> GetStudentExamResult(int ketQuaId, string studentId)
        {
            var ketQua = await _context.KetQuas
                .AsNoTracking()
                .Include(kq => kq.MadeNavigation)
                    .ThenInclude(d => d.ChiTietDeThis)
                        .ThenInclude(ct => ct.MacauhoiNavigation)
                            .ThenInclude(ch => ch.CauTraLois)
                .FirstOrDefaultAsync(kq => kq.Makq == ketQuaId && kq.Manguoidung == studentId);

            if (ketQua is null) return null;

            var deThi = ketQua.MadeNavigation;

            var resultDto = new ExamReviewDto
            {
                Diem = deThi.Xemdiemthi == true ? ketQua.Diemthi : null,
                SoCauDung = deThi.Xemdiemthi == true ? ketQua.Socaudung : null,
                TongSoCau = deThi.Xemdiemthi == true ? deThi.ChiTietDeThis.Count : null,
                Hienthibailam = deThi.Hienthibailam ?? false,
                Xemdapan = deThi.Xemdapan ?? false,
                Xemdiemthi = deThi.Xemdiemthi ?? false,
            };

            var studentAnswers = await _context.ChiTietTraLoiSinhViens
                .Where(ct => ct.Makq == ketQuaId)
                .ToListAsync();

            var correctAnswersLookup = deThi.ChiTietDeThis
                .SelectMany(ct => ct.MacauhoiNavigation.CauTraLois)
                .Where(ans => ans.Dapan == true)
                .ToLookup(ans => ans.Macauhoi, ans => ans);

            if (deThi.Hienthibailam == true)
            {
                var questions = deThi.ChiTietDeThis.Select(ct => ct.MacauhoiNavigation).ToList();

                if (deThi.Troncauhoi == true)
                {
                    var seed = deThi.Made.GetHashCode() + studentId.GetHashCode();
                    var seededRandom = new Random(seed);
                    questions = questions.OrderBy(q => seededRandom.Next()).ToList();
                }

                foreach (var question in questions)
                {
                    var questionDto = new ExamReviewQuestionDto
                    {
                        Macauhoi = question.Macauhoi,
                        Noidung = question.Noidung,
                        Loaicauhoi = question.Loaicauhoi,
                        Hinhanhurl = question.Hinhanhurl!,
                    };

                    var answers = question.CauTraLois.ToList();

                    if (question.Daodapan == true)
                    {
                        var answerSeed = deThi.Made.GetHashCode() + studentId.GetHashCode() + question.Macauhoi;
                        var answerSeededRandom = new Random(answerSeed);
                        answers = answers.OrderBy(a => answerSeededRandom.Next()).ToList();
                    }

                    foreach (var answer in answers)
                    {
                        questionDto.Answers.Add(new ExamReviewAnswerOptionDto
                        {
                            Macautl = answer.Macautl,
                            Noidungtl = answer.Noidungtl,
                            Dapan = answer.Dapan
                        });
                    }

                    if (question.Loaicauhoi == "single_choice")
                    {
                        var selectedOption = studentAnswers.FirstOrDefault(sa => sa.Macauhoi == question.Macauhoi && sa.Dapansv == 1);
                        questionDto.StudentSelectedAnswerId = selectedOption?.Macautl;
                    }
                    else if (question.Loaicauhoi == "multiple_choice")
                    {
                        questionDto.StudentSelectedAnswerIds = studentAnswers
                            .Where(sa => sa.Macauhoi == question.Macauhoi && sa.Dapansv == 1)
                            .Select(sa => sa.Macautl)
                            .ToList();
                    }
                    else if (question.Loaicauhoi == "essay")
                    {
                        var essayAnswer = studentAnswers.FirstOrDefault(sa => sa.Macauhoi == question.Macauhoi);
                        questionDto.StudentAnswerText = essayAnswer?.Dapantuluansv!;
                    }
                    resultDto.Questions.Add(questionDto);
                }
            }

            if (deThi.Xemdapan == true)
            {
                resultDto.CorrectAnswers = new Dictionary<int, object>();
                foreach (var questionDetail in deThi.ChiTietDeThis)
                {
                    var question = questionDetail.MacauhoiNavigation;
                    if (question.Loaicauhoi == "single_choice" || question.Loaicauhoi == "multiple_choice")
                    {
                        var correctIds = correctAnswersLookup[question.Macauhoi].Select(a => a.Macautl).ToList();
                        if (correctIds.Count != 0)
                        {
                            resultDto.CorrectAnswers[question.Macauhoi] = correctIds;
                        }
                    }
                    else if (question.Loaicauhoi == "essay")
                    {
                        var correctText = correctAnswersLookup[question.Macauhoi].FirstOrDefault()?.Noidungtl;
                        if (!string.IsNullOrWhiteSpace(correctText))
                        {
                            resultDto.CorrectAnswers[question.Macauhoi] = correctText;
                        }
                    }
                }
            }

            return resultDto;
        }
        public async Task<bool> UpdateStudentAnswer(UpdateAnswerRequestDto request, string studentId)
        {
            var ketQua = await _context.KetQuas
                     .AsNoTracking()
                     .FirstOrDefaultAsync(kq => kq.Makq == request.KetQuaId && kq.Manguoidung == studentId) ?? throw new KeyNotFoundException("Không tìm thấy kết quả bài thi hoặc sinh viên không có quyền truy cập.");

            var maKqParam = new SqlParameter("@MaKQ", request.KetQuaId);
            var maCauHoiParam = new SqlParameter("@MaCauHoi", request.Macauhoi);
            var maCauTlParam = new SqlParameter("@MaCauTL", request.Macautl == 0 ? DBNull.Value : (object)request.Macautl);
            var dapAnSvParam = new SqlParameter("@DapAnSV", request.Dapansv.HasValue ? (object)request.Dapansv.Value : DBNull.Value);
            var dapAnTuLuanSvParam = new SqlParameter("@DapAnTuLuanSV", string.IsNullOrEmpty(request.Dapantuluansv) ? DBNull.Value : (object)request.Dapantuluansv);

            if (maCauTlParam.Value == DBNull.Value) maCauTlParam.IsNullable = true;
            if (dapAnSvParam.Value == DBNull.Value) dapAnSvParam.IsNullable = true;
            if (dapAnTuLuanSvParam.Value == DBNull.Value) dapAnTuLuanSvParam.IsNullable = true;

            await _context.Database.ExecuteSqlRawAsync(
                "EXEC dbo.CapNhatDapAn @MaKQ, @MaCauHoi, @MaCauTL, @DapAnSV, @DapAnTuLuanSV",
                maKqParam,
                maCauHoiParam,
                maCauTlParam,
                dapAnSvParam,
                dapAnTuLuanSvParam
            );

            return true;
        }

        public async Task<List<DeThiViewModel>> GetMyCreatedExamsAsync(string teacherId)
        {
            var assignedSubjectIds = await _context.PhanCongs
                .Where(pc => pc.Manguoidung == teacherId)
                .Select(pc => pc.Mamonhoc)
                .Distinct()
                .ToListAsync();

            if (!assignedSubjectIds.Any())
            {
                return new List<DeThiViewModel>();
            }

            // SỬA: Bỏ điều kiện d.Trangthai == true để hiển thị cả đề thi đã đóng
            // Giáo viên cần thấy tất cả đề thi để có thể bật lại khi cần
            var deThis = await _context.DeThis
                .Include(d => d.Malops)
                .Where(d => assignedSubjectIds.Contains(d.Monthi ?? 0) &&
                           d.Nguoitao == teacherId)
                .OrderByDescending(d => d.Thoigiantao)
                .ToListAsync();

            var viewModels = deThis.Select(d => new DeThiViewModel
            {
                Made = d.Made,
                Tende = d.Tende,
                Thoigianbatdau = d.Thoigiantbatdau ?? DateTime.MinValue,
                Thoigianketthuc = d.Thoigianketthuc ?? DateTime.MinValue,
                Monthi = d.Monthi ?? 0,
                GiaoCho = d.Malops.Count != 0 ? string.Join(", ", d.Malops.Select(l => $"{l.Tenlop} (NH {l.Namhoc} - HK{l.Hocky})")) : "Chưa giao",
                Trangthai = d.Trangthai ?? false,
                Xemdiemthi = d.Xemdiemthi ?? false,
                Hienthibailam = d.Hienthibailam ?? false,
                Xemdapan = d.Xemdapan ?? false,
                Troncauhoi = d.Troncauhoi ?? false
            }).ToList();

            return viewModels;
        }

        public async Task<ChuyenTabResponseDto> TangSoLanChuyenTab(int ketQuaId, string studentId)
        {
            const int gioiHan = 5;

            var ketQua = await _context.KetQuas
                .FirstOrDefaultAsync(kq => kq.Makq == ketQuaId && kq.Manguoidung == studentId);

            if (ketQua == null)
            {
                throw new KeyNotFoundException("Không tìm thấy kết quả bài thi hoặc sinh viên không có quyền truy cập.");
            }

            if (ketQua.Diemthi.HasValue && ketQua.Diemthi > 0)
            {
                return new ChuyenTabResponseDto
                {
                    SoLanHienTai = ketQua.Solanchuyentab ?? 0,
                    NopBai = false,
                    ThongBao = "Bài thi đã được nộp, không thể theo dõi chuyển tab.",
                    GioiHan = gioiHan
                };
            }

            ketQua.Solanchuyentab = (ketQua.Solanchuyentab ?? 0) + 1;
            await _context.SaveChangesAsync();

            var SoLanHienTai = ketQua.Solanchuyentab.Value;
            var NopBai = SoLanHienTai >= gioiHan;;

            string message;
            if (NopBai)
            {
                message = $"Bạn đã chuyển tab {SoLanHienTai} lần. Bài thi sẽ được tự động nộp do vi phạm quy định.";
            }
            else
            {
                var conLai = gioiHan - SoLanHienTai;
                message = $"Cảnh báo: Bạn đã chuyển tab {SoLanHienTai}/{gioiHan} lần. Còn {conLai} lần nữa bài thi sẽ tự động nộp.";
            }

            return new ChuyenTabResponseDto
            {
                SoLanHienTai = SoLanHienTai,
                NopBai = NopBai,
                ThongBao = message,
                GioiHan = gioiHan
            };
        }

        public async Task<bool> ToggleExamStatusAsync(int examId, bool trangthai)
        {
            var currentUserId = GetCurrentUserId();
            var deThi = await _context.DeThis.FindAsync(examId);

            if (deThi == null) return false;

            // Check if user has permission to modify this exam
            if (deThi.Nguoitao != currentUserId)
            {
                throw new UnauthorizedAccessException("Bạn không có quyền thay đổi trạng thái đề thi này.");
            }

            deThi.Trangthai = trangthai;
            await _context.SaveChangesAsync();

            return true;
        }
    }
}
