namespace CKCQUIZZ.Server.Viewmodels.KetQua
{
    public class FindKetQuaResponseDto
    {
        public bool Success { get; set; }
        public string Message { get; set; } = string.Empty;
        public int? KetQuaId { get; set; }
        public int? ExamId { get; set; }
        public string? StudentId { get; set; }
        public double? Score { get; set; }
    }
}
