using System.Diagnostics;
using Mapiticos.Models;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace Mapiticos.Controllers
{
    [AllowAnonymous] // La página de inicio es pública
    public class HomeController : Controller
    {
        public IActionResult Index()
        {
            // Si ya inició sesión, no tiene sentido mostrarle el inicio
            if (User.Identity?.IsAuthenticated == true)
            {
                return RedirectToAction("Index", "Feed");
            }
            return View();
        }

        public IActionResult Privacy()
        {
            return View();
        }

        [ResponseCache(Duration = 0, Location = ResponseCacheLocation.None, NoStore = true)]
        public IActionResult Error()
        {
            return View(new ErrorViewModel { RequestId = Activity.Current?.Id ?? HttpContext.TraceIdentifier });
        }
    }
}