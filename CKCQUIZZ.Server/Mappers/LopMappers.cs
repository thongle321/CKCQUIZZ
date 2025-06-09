using CKCQUIZZ.Server.Models;
using CKCQUIZZ.Server.Viewmodels.Lop;

public static class LopMappers
{
    public static LopDTO ToDto(Lop entity) => new LopDTO
    {
        Malop = entity.Malop,
        Tenlop = entity.Tenlop,
        Mamoi = entity.Mamoi!,
        Siso = entity.Siso,
        Ghichu = entity.Ghichu,
        Namhoc = entity.Namhoc,
        Hocky = entity.Hocky,
        Trangthai = entity.Trangthai,
        Hienthi = entity.Hienthi,
        Giangvien = entity.Giangvien,
        Mamonhoc = entity.Mamonhoc
    };

    public static Lop ToEntity(LopDTO dto) => new Lop
    {
        Tenlop = dto.Tenlop,
        Mamoi = dto.Mamoi,
        Siso = dto.Siso,
        Ghichu = dto.Ghichu,
        Namhoc = dto.Namhoc,
        Hocky = dto.Hocky,
        Trangthai = dto.Trangthai,
        Hienthi = dto.Hienthi,
        Giangvien = dto.Giangvien,
        Mamonhoc = dto.Mamonhoc
    };

    public static void UpdateEntity(Lop entity, LopDTO dto)
    {
        entity.Tenlop = dto.Tenlop;
        entity.Mamoi = dto.Mamoi;
        entity.Siso = dto.Siso;
        entity.Ghichu = dto.Ghichu;
        entity.Namhoc = dto.Namhoc;
        entity.Hocky = dto.Hocky;
        entity.Trangthai = dto.Trangthai;
        entity.Hienthi = dto.Hienthi;
        entity.Giangvien = dto.Giangvien;
        entity.Mamonhoc = dto.Mamonhoc;
    }
}
