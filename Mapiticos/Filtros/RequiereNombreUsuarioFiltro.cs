using System.Security.Claims;
using Mapiticos.Repositorios;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.Filters;

namespace Mapiticos.Filtros
{
    // Marca para las páginas que se pueden ver SIN tener @usuario todavía
    [AttributeUsage(AttributeTargets.Class | AttributeTargets.Method)]
    public class SinNombreUsuarioRequeridoAttribute : Attribute { }

    // Antes de cada página: si la persona inició sesión y no tiene @usuario,
    // la manda a elegirlo.
    public class RequiereNombreUsuarioFiltro : IAsyncActionFilter
    {
        private readonly IPerfilRepositorio _perfilRepositorio;

        public RequiereNombreUsuarioFiltro(IPerfilRepositorio perfilRepositorio)
        {
            _perfilRepositorio = perfilRepositorio;
        }

        public async Task OnActionExecutionAsync(ActionExecutingContext context, ActionExecutionDelegate next)
        {
            var usuario = context.HttpContext.User;

            var exenta = context.ActionDescriptor.EndpointMetadata
                .OfType<SinNombreUsuarioRequeridoAttribute>()
                .Any();

            if (!exenta && usuario.Identity?.IsAuthenticated == true)
            {
                var usuarioId = usuario.FindFirstValue(ClaimTypes.NameIdentifier);
                if (usuarioId != null && await _perfilRepositorio.ObtenerNombreUsuarioAsync(usuarioId) == null)
                {
                    context.Result = new RedirectToActionResult("ElegirUsuario", "Perfil", null);
                    return;
                }
            }

            await next();
        }
    }
}