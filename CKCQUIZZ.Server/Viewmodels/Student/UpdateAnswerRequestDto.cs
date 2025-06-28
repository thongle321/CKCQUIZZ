namespace CKCQUIZZ.Server.Viewmodels.Student
{
    public class UpdateAnswerRequestDto
    {
        public int KetQuaId { get; set; }
        public int Macauhoi { get; set; }
        public int Macautl { get; set; } 
        public int? Dapansv { get; set; } 
        public string? Dapantuluansv { get; set; }
    }
}