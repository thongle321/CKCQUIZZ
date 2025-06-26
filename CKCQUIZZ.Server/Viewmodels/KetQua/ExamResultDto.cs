namespace CKCQUIZZ.Server.Viewmodels.KetQua
{
    public class ExamResultDto
    {
        public int Makq { get; set; }
        public int Made { get; set; }
        public string Manguoidung { get; set; } = null!;
        public string? TenNguoiDung { get; set; }
        public string? TenDeThi { get; set; }
        public string? TenMonHoc { get; set; }
        public double? Diemthi { get; set; }
        public DateTime? Thoigianvaothi { get; set; }
        public int? Thoigiansolambai { get; set; } // Thời gian làm bài (phút)
        public int? Socaudung { get; set; }
        public int? TongSoCau { get; set; }
        public int? Solanchuyentab { get; set; }
        public DateTime? NgayThi { get; set; }
        public string? TrangThai { get; set; } // "DaHoanThanh", "DangLam", "QuaHan"
    }

    public class ExamResultDetailDto
    {
        public ExamResultDto KetQua { get; set; } = null!;
        public List<StudentAnswerDetailDto> ChiTietTraLoi { get; set; } = new List<StudentAnswerDetailDto>();
    }

    // DTO phù hợp với Flutter model ExamResult (cho submit response)
    public class ExamResultForFlutterDto
    {
        public int Makq { get; set; }
        public int Made { get; set; }
        public string Manguoidung { get; set; } = null!;
        public double Diem { get; set; }
        public int Socaudung { get; set; }
        public int Tongcauhoi { get; set; }
        public DateTime Thoigianbatdau { get; set; }
        public DateTime Thoigianketthuc { get; set; }
        public DateTime Thoigianhoanthanh { get; set; }
    }

    // DTO phù hợp với Flutter model ExamResultDetail
    public class ExamResultDetailForFlutterDto
    {
        public int Makq { get; set; }
        public int Made { get; set; }
        public string Tende { get; set; } = null!;
        public string Manguoidung { get; set; } = null!;
        public string Hoten { get; set; } = null!;
        public double Diem { get; set; }
        public int Socaudung { get; set; }
        public int Tongcauhoi { get; set; }
        public DateTime Thoigianbatdau { get; set; }
        public DateTime Thoigianketthuc { get; set; }
        public DateTime Thoigianhoanthanh { get; set; }
        public List<StudentAnswerDetailDto> ChiTietTraLoi { get; set; } = new List<StudentAnswerDetailDto>();
    }

    public class StudentAnswerDetailDto
    {
        public int Macauhoi { get; set; }
        public string NoiDungCauHoi { get; set; } = null!;
        public int? MacautraloiChon { get; set; }
        public string? NoiDungTraLoiChon { get; set; }
        public int MacautraloiDung { get; set; }
        public string NoiDungTraLoiDung { get; set; } = null!;
        public bool LaDung { get; set; }
        public double? DiemKetQua { get; set; }
        public DateTime? Thoigiantraloi { get; set; }
    }

    public class ExamStatisticsDto
    {
        public int Made { get; set; }
        public string TenDeThi { get; set; } = null!;
        public int TongSoSinhVien { get; set; }
        public int SoSinhVienDaThi { get; set; }
        public int SoSinhVienChuaThi { get; set; }
        public double? DiemTrungBinh { get; set; }
        public double? DiemCaoNhat { get; set; }
        public double? DiemThapNhat { get; set; }
        public int SoSinhVienDat { get; set; } // Điểm >= 5
        public int SoSinhVienKhongDat { get; set; } // Điểm < 5
        public double TyLeDat { get; set; } // %
        public List<ScoreDistributionDto> PhanBoTiem { get; set; } = new List<ScoreDistributionDto>();
    }

    public class ScoreDistributionDto
    {
        public string KhoangDiem { get; set; } = null!; // "0-2", "2-4", "4-6", "6-8", "8-10"
        public int SoLuong { get; set; }
        public double TyLe { get; set; } // %
    }
}
