using CKCQUIZZ.Server.Viewmodels.DeThi;
using CKCQUIZZ.Server.Viewmodels.Student;

namespace CKCQUIZZ.Server.Interfaces
{
    public interface IDeThiService
    {
        Task<List<DeThiViewModel>> GetAllAsync();
<<<<<<< HEAD
        Task<List<DeThiViewModel>> GetAllByTeacherAsync(string teacherId);
        Task<DeThiDetailViewModel> GetByIdAsync(int id);
=======
        Task<DeThiDetailViewModel?> GetByIdAsync(int id);
>>>>>>> b6807776675e9b68fa2a543e6c838f52a42f6b83
        Task<DeThiViewModel> CreateAsync(DeThiCreateRequest request);
        Task<bool> UpdateAsync(int id, DeThiUpdateRequest request);
        Task<bool> DeleteAsync(int id);
        Task<TestResultResponseDto?> GetTestResultsAsync(int deThiId);
        Task<bool> CapNhatChiTietDeThiAsync(int maDe, CapNhatChiTietDeThiRequest request);
        Task<IEnumerable<ExamForClassDto>> GetExamsForClassAsync(int classId, string studentId);
        Task<IEnumerable<ExamForClassDto>> GetAllExamsForStudentAsync(string studentId);
        Task<StudentExamDetailDto?> GetExamForStudent(int deThiId, string studentId);
        Task<StartExamResponseDto> StartExam(StartExamRequestDto request, string studentId); // Add this line
        Task<ExamResultDto> SubmitExam(SubmitExamRequestDto submission, string studentId);
        Task<ExamReviewDto?> GetStudentExamResult(int ketQuaId, string studentId);
        Task<bool> UpdateStudentAnswer(UpdateAnswerRequestDto request, string studentId);
        Task<object> GetQuestionsForStudentAsync(int examId, string studentId);
        Task<RecalculateScoresResponseDto> RecalculateExamScores(int? examId = null);
        Task<object> DebugExamData(int examId);
    }
}
