using CKCQUIZZ.Server.Models;
using Microsoft.AspNetCore.Mvc;

namespace CKCQUIZZ.Server.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class SubjectController(CkcquizzContext _context) : ControllerBase
    {
    }

}

