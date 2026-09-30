using System.Security.Claims;
using Mapiticos.Repositorios;
using Microsoft.AspNetCore.Mvc;

namespace Mapiticos.Controllers
{
    public class PerfilController : Controller
    {
        private readonly IPerfilRepositorio _perfilRepositorio;

        // .NET inyecta el repositorio automáticamente (inyección de dependencias)
        public PerfilController(IPerfilRepositorio perfilRepositorio)
        {
            _perfilRepositorio = perfilRepositorio;
        }

        public async Task<IActionResult> Index()
        {
            // Id del usuario que inició sesión (el mismo Id de AspNetUsers)
            var usuarioId = User.FindFirstValue(ClaimTypes.NameIdentifier);
            if (usuarioId == null)
            {
                return Challenge(); // lo manda al login
            }

            var perfil = await _perfilRepositorio.ObtenerPerfilAsync(usuarioId);
            if (perfil == null)
            {
                return NotFound();
            }

            return View(perfil);
        }
    }
}