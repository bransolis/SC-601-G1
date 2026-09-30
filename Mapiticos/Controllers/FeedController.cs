using Mapiticos.Models.ViewModels;
using Microsoft.AspNetCore.Mvc;

namespace Mapiticos.Controllers
{
    public class FeedController : Controller
    {
        public IActionResult Index()
        {
            // TEMPORAL: datos de ejemplo.
            // Cuando este la BD, esta lista la va a traer el repositorio.
            var publicaciones = new List<PublicacionFeedViewModel>
            {
                new PublicacionFeedViewModel
                {
                    AventuraId = 1,
                    NombreUsuario = "ana.rodz",
                    Lugar = "Volcán Arenal, La Fortuna",
                    Descripcion = "Amanecer con el volcán despejado. Valió la madrugada.",
                    CantidadLikes = 86,
                    LeDiLike = true,
                    FechaPublicacion = DateTime.Now.AddHours(-2),
                    Etiquetas = new List<EtiquetaViewModel>
                    {
                        new EtiquetaViewModel { Nombre = "Vista", Icono = "ti-sunset" },
                        new EtiquetaViewModel { Nombre = "Hiking", Icono = "ti-mountain" }
                    }
                },
                new PublicacionFeedViewModel
                {
                    AventuraId = 2,
                    NombreUsuario = "luis.m",
                    Lugar = "Café en Barva, Heredia",
                    Descripcion = "Nueva parada obligada antes de subir al volcán.",
                    CantidadLikes = 41,
                    FechaPublicacion = DateTime.Now.AddDays(-1),
                    Etiquetas = new List<EtiquetaViewModel>
                    {
                        new EtiquetaViewModel { Nombre = "Café", Icono = "ti-coffee" }
                    }
                }
            };

            return View(publicaciones);
        }
    }
}