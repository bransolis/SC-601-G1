using System.Security.Claims;
using Mapiticos.Models.ViewModels;
using Mapiticos.Repositorios;
using Microsoft.AspNetCore.Mvc;

namespace Mapiticos.Controllers
{
    public class PerfilController : Controller
    {
        private readonly IPerfilRepositorio _perfilRepositorio;

        public PerfilController(IPerfilRepositorio perfilRepositorio)
        {
            _perfilRepositorio = perfilRepositorio;
        }

        private string? UsuarioActualId() => User.FindFirstValue(ClaimTypes.NameIdentifier);

        // ===== Ver perfil =====
        public async Task<IActionResult> Index()
        {
            var usuarioId = UsuarioActualId();
            if (usuarioId == null) return Challenge();

            var perfil = await _perfilRepositorio.ObtenerPerfilAsync(usuarioId);
            if (perfil == null) return NotFound();

            return View(perfil);
        }

        // ===== Editar perfil: mostrar el formulario =====
        [HttpGet]
        public async Task<IActionResult> Editar()
        {
            var usuarioId = UsuarioActualId();
            if (usuarioId == null) return Challenge();

            var modelo = await _perfilRepositorio.ObtenerParaEditarAsync(usuarioId);
            if (modelo == null) return NotFound();

            return View(modelo);
        }

        // ===== Editar perfil: guardar =====
        [HttpPost]
        [ValidateAntiForgeryToken]
        public async Task<IActionResult> Editar(EditarPerfilViewModel modelo)
        {
            var usuarioId = UsuarioActualId();
            if (usuarioId == null) return Challenge();

            if (!AvatarValidador.EsValido(modelo.AvatarUrl))
            {
                ModelState.AddModelError(nameof(modelo.AvatarUrl), "Ese avatar no es válido. Probá creándolo de nuevo.");
            }

            if (!ModelState.IsValid)
            {
                var correo = User.Identity?.Name ?? "";
                modelo.NombreUsuario = correo.Contains('@') ? correo.Split('@')[0] : correo;
                return View(modelo);
            }

            await _perfilRepositorio.GuardarAsync(usuarioId, modelo);

            TempData["Mensaje"] = "¡Listo! Tu perfil se actualizó.";
            return RedirectToAction(nameof(Index));
        }
    }
}