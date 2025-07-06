namespace CKCQUIZZ.Server.Viewmodels.KetQua
{
    public class UpdateScoreResponseDto
    {
        public bool Success { get; set; }
        public string Message { get; set; } = string.Empty;
        public int? KetQuaId { get; set; }
        public double? NewScore { get; set; }
    }
}
