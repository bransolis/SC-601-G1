using Mapiticos.Filtros;
using Mapiticos.Models.ViewModels;
using Mapiticos.Repositorios;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Identity;
using Microsoft.AspNetCore.Mvc;

namespace Mapiticos.Controllers
{
    [AllowAnonymous]            // Se usa antes de tener cuenta
    [SinNombreUsuarioRequerido] // y todavía no hay @usuario
    public class CuentaController : Controller
    {
        private readonly UserManager<IdentityUser> _userManager;
        private readonly SignInManager<IdentityUser> _signInManager;
        private readonly IPerfilRepositorio _perfilRepositorio;

        public CuentaController(
            UserManager<IdentityUser> userManager,
            SignInManager<IdentityUser> signInManager,
            IPerfilRepositorio perfilRepositorio)
        {
            _userManager = userManager;
            _signInManager = signInManager;
            _perfilRepositorio = perfilRepositorio;
        }

        // ===== Crear cuenta (el formulario de la bienvenida) =====
        [HttpPost]
        [ValidateAntiForgeryToken]
        public async Task<IActionResult> Registrar(RegistroViewModel modelo)
        {
            // 1) Revisar el @usuario
            if (ReglasNombreUsuario.EsReservado(modelo.NombreUsuario))
            {
                ModelState.AddModelError(nameof(modelo.NombreUsuario), "Ese nombre está reservado. Probá con otro.");
            }
            else if (ModelState.IsValid &&
                     !await _perfilRepositorio.NombreUsuarioDisponibleAsync(modelo.NombreUsuario, ""))
            {
                ModelState.AddModelError(nameof(modelo.NombreUsuario), "Ese nombre de usuario ya está en uso.");
            }

            if (!ModelState.IsValid) return VolverAlRegistro(modelo);

            // 2) Crear la cuenta en Identity (GestorUsuarios le asigna el rol "Usuario")
            var usuario = new IdentityUser { UserName = modelo.Correo, Email = modelo.Correo };
            var resultado = await _userManager.CreateAsync(usuario, modelo.Clave);

            if (!resultado.Succeeded)
            {
                foreach (var error in resultado.Errors)
                {
                    ModelState.AddModelError(CampoDelError(error), Traducir(error));
                }
                return VolverAlRegistro(modelo);
            }

            // 3) Guardar su @usuario.
            //    Si justo alguien lo tomó en ese segundo, el filtro le pedirá otro al entrar.
            await _perfilRepositorio.AsignarNombreUsuarioAsync(usuario.Id, modelo.NombreUsuario);

            // 4) Iniciar sesión y llevarlo a su perfil
            await _signInManager.SignInAsync(usuario, isPersistent: false);

            TempData["Mensaje"] = $"¡Te damos la bienvenida, @{modelo.NombreUsuario}! Ya podés personalizar tu perfil.";
            return RedirectToAction("Index", "Perfil");
        }

        // ===== Revisión en vivo del @usuario (sin haber iniciado sesión) =====
        [HttpGet]
        public async Task<IActionResult> UsuarioDisponible(string nombre)
        {
            nombre = (nombre ?? "").Trim().ToLowerInvariant();

            if (!ReglasNombreUsuario.FormatoValido(nombre))
                return Json(new { disponible = false, mensaje = ReglasNombreUsuario.MensajeFormato });

            if (ReglasNombreUsuario.EsReservado(nombre))
                return Json(new { disponible = false, mensaje = "Ese nombre está reservado." });

            var disponible = await _perfilRepositorio.NombreUsuarioDisponibleAsync(nombre, "");
            return Json(new { disponible, mensaje = disponible ? "¡Disponible!" : "Ya está en uso." });
        }

        // Si hay errores, vuelve a mostrar la bienvenida con los mensajes
        private IActionResult VolverAlRegistro(RegistroViewModel modelo) =>
            View("~/Views/Home/Index.cshtml", modelo);

        // A qué campo pertenece cada error de Identity
        private static string CampoDelError(IdentityError error)
        {
            if (error.Code.StartsWith("Password")) return nameof(RegistroViewModel.Clave);
            if (error.Code is "DuplicateUserName" or "DuplicateEmail" or "InvalidEmail" or "InvalidUserName")
                return nameof(RegistroViewModel.Correo);
            return string.Empty; // error general
        }

        // Los errores d a español
        private static string Traducir(IdentityError error) => error.Code switch
        {
            "PasswordTooShort" => "La contraseña debe tener al menos 6 caracteres.",
            "PasswordRequiresNonAlphanumeric" => "La contraseña necesita al menos un símbolo (por ejemplo ! o #).",
            "PasswordRequiresDigit" => "La contraseña necesita al menos un número.",
            "PasswordRequiresUpper" => "La contraseña necesita al menos una mayúscula.",
            "PasswordRequiresLower" => "La contraseña necesita al menos una minúscula.",
            "DuplicateUserName" or "DuplicateEmail" => "Ya existe una cuenta con ese correo.",
            "InvalidEmail" or "InvalidUserName" => "Ese correo no parece válido.",
            _ => error.Description
        };
    }
}