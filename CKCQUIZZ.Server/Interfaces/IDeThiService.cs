using CKCQUIZZ.Server.Viewmodels.DeThi;
using CKCQUIZZ.Server.Viewmodels.Student;

namespace CKCQUIZZ.Server.Interfaces
{
    public interface IDeThiService
    {
        Task<List<DeThiViewModel>> GetAllAsync();
        Task<DeThiDetailViewModel?> GetByIdAsync(int id);
        Task<DeThiViewModel> CreateAsync(DeThiCreateRequest request);
        Task<bool> UpdateAsync(int id, DeThiUpdateRequest request);
        Task<bool> DeleteAsync(int id);
        Task<bool> RestoreAsync(int id);
        Task<bool> HardDeleteAsync(int id);
        Task<TestResultResponseDto?> GetTestResultsAsync(int deThiId);
        Task<bool> CapNhatChiTietDeThiAsync(int maDe, CapNhatChiTietDeThiRequest request);
        Task<IEnumerable<ExamForClassDto>> GetExamsForClassAsync(int classId, string studentId);
        Task<IEnumerable<ExamForClassDto>> GetAllExamsForStudentAsync(string studentId);
        Task<StudentExamDetailDto?> GetExamForStudent(int deThiId, string studentId);
        Task<StartExamResponseDto> StartExam(StartExamRequestDto request, string studentId);
        Task<ExamResultDto> SubmitExam(SubmitExamRequestDto submission, string studentId);
        Task<ExamReviewDto?> GetStudentExamResult(int ketQuaId, string studentId);
        Task<bool> UpdateStudentAnswer(UpdateAnswerRequestDto request, string studentId);
        Task<List<DeThiViewModel>> GetMyCreatedExamsAsync(string teacherId);
    }
}
