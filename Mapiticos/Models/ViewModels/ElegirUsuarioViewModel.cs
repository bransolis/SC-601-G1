using System.ComponentModel.DataAnnotations;
using System.Text.RegularExpressions;

namespace Mapiticos.Models.ViewModels
{
    // Reglas del @usuario, en un solo lugar para toda la app
    public static class ReglasNombreUsuario
    {
        // 3 a 30: minúsculas, números, punto y guion bajo; sin empezar ni terminar en punto
        public const string Patron = @"^(?!\.)(?!.*\.$)[a-z0-9._]{3,30}$";

        public const string MensajeFormato =
            "Usá de 3 a 30 letras minúsculas, números, punto o guion bajo (sin empezar ni terminar en punto).";

        private static readonly HashSet<string> Reservados = new()
        {
            "admin", "administrador", "mapiticos", "soporte", "ayuda", "perfil", "mapa"
        };

        public static bool FormatoValido(string? nombre) =>
            nombre != null && Regex.IsMatch(nombre, Patron);

        public static bool EsReservado(string? nombre) =>
            nombre != null && Reservados.Contains(nombre);
    }

    // El formulario de "Elegí tu @usuario"
    public class ElegirUsuarioViewModel
    {
        [Required(ErrorMessage = "Elegí un nombre de usuario.")]
        [RegularExpression(ReglasNombreUsuario.Patron, ErrorMessage = ReglasNombreUsuario.MensajeFormato)]
        [Display(Name = "Nombre de usuario")]
        public string NombreUsuario { get; set; } = "";
    }
}