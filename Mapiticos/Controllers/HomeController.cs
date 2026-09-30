using System.Diagnostics;
using Mapiticos.Models;
using System.Diagnostics;
using Mapiticos.Filtros;
using Mapiticos.Models;
using Mapiticos.Models.ViewModels;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace Mapiticos.Controllers
{
    [AllowAnonymous]
    [SinNombreUsuarioRequerido]
    public class HomeController : Controller
    {
        public IActionResult Index()
        {
            if (User.Identity?.IsAuthenticated == true)
            {
                return RedirectToAction("Index", "Feed");
            }
            return View(new RegistroViewModel());
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