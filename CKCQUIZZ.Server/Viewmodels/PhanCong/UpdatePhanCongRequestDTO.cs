namespace CKCQUIZZ.Server.Viewmodels.PhanCong
{
    public class UpdatePhanCongRequestDTO
    {
        public string GiangVienId { get; set; } = default!;
        public List<int> ListMaMonHoc { get; set; } = [];
    }
}