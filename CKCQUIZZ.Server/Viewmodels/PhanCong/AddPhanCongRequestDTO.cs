namespace CKCQUIZZ.Server.Viewmodels.PhanCong
{
    public class AddPhanCongRequestDTO
    {
        public string GiangVienId { get; set; } = default!;
        public List<int> ListMaMonHoc { get; set; } = [];
    }
}
