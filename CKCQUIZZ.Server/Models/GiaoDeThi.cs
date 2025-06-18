namespace CKCQUIZZ.Server.Models
{
    public partial class GiaoDeThi
    {
        public int Made { get; set; }

        public int Malop { get; set; }

        public virtual DeThi MadeNavigation { get; set; } = null!;

        public virtual Lop MalopNavigation { get; set; } = null!;
    }

}

