using CKCQUIZZ.Server.Viewmodels.Role;

namespace CKCQUIZZ.Server.Viewmodels
{
    public class PagedResult<T>
    {
        public int TotalCount { get; set; }
        public List<T> Items { get; set; } = default!;


    }
}
