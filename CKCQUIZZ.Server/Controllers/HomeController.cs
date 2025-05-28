using Microsoft.AspNetCore.Mvc;

namespace CKCQUIZZ.Server.Controllers
{
    public class HomeController : Controller
    {
        public IActionResult Dashboard()
        {
            return View();
        }
    }
}
