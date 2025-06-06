using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace CKCQUIZZ.Server.Models;

public class DanhSachLop
{
    [Key]
    public int Malop { get; set; }

    [Key]
    public int Mamonhoc { get; set; }

    public virtual Lop LopNavigation  { get; set; } = null!;
    public virtual MonHoc MonHocNavigation  { get; set; } = null!;
}
