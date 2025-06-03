using CKCQUIZZ.Server.Viewmodels;
using CKCQUIZZ.Server.Viewmodels.Subject;

namespace CKCQUIZZ.Server.Interfaces
{
    public interface ISubjectService
    {
        Task<ResponseDTO?> GetSubject(string subjectName);
        Task<ResponseDTO?> GetAllSubjectsAsync();
        Task<ResponseDTO?> GetSubjectByIdAsync(int id);
        Task<ResponseDTO?> CreateSubjectsAsync(MonHocDTO monHocDTO);
        Task<ResponseDTO?> UpdateSubjectsAsync(MonHocDTO monHocDTO);
        Task<ResponseDTO?> DeleteSubjectsAsync(int id);

    }

}

