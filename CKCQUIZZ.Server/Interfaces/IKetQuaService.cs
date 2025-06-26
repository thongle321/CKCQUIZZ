using CKCQUIZZ.Server.Viewmodels.KetQua;

namespace CKCQUIZZ.Server.Interfaces
{
    public interface IKetQuaService
    {
        /// <summary>
        /// Submit bài thi của sinh viên
        /// </summary>
        Task<ExamResultForFlutterDto> SubmitExamAsync(SubmitExamRequestDto request);

        /// <summary>
        /// Lấy kết quả thi của sinh viên
        /// </summary>
        Task<List<ExamResultDto>> GetResultsByStudentAsync(string studentId);

        /// <summary>
        /// Lấy chi tiết kết quả thi
        /// </summary>
        Task<ExamResultDetailForFlutterDto> GetResultDetailAsync(int resultId, string studentId);

        /// <summary>
        /// Lấy kết quả thi theo đề thi (cho giáo viên)
        /// </summary>
        Task<List<ExamResultDto>> GetResultsByExamAsync(int examId, string teacherId);

        /// <summary>
        /// Lấy thống kê kết quả thi
        /// </summary>
        Task<ExamStatisticsDto> GetExamStatisticsAsync(int examId, string teacherId);

        /// <summary>
        /// Kiểm tra sinh viên đã thi chưa
        /// </summary>
        Task<bool> HasStudentTakenExamAsync(int examId, string studentId);
    }
}
