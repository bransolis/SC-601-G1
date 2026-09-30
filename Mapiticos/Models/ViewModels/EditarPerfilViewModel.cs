using System.ComponentModel.DataAnnotations;
using System.Text.RegularExpressions;

namespace Mapiticos.Models.ViewModels
{
    public class EditarPerfilViewModel
    {
        [Required(ErrorMessage = "Elegí un nombre de usuario.")]
        [RegularExpression(ReglasNombreUsuario.Patron, ErrorMessage = ReglasNombreUsuario.MensajeFormato)]
        [Display(Name = "Nombre de usuario")]
        public string NombreUsuario { get; set; } = "";

        [Required(ErrorMessage = "Escribí cómo querés que te llamen.")]
        [StringLength(100, ErrorMessage = "Máximo 100 caracteres.")]
        [Display(Name = "Nombre para mostrar")]
        public string NombreMostrar { get; set; } = "";

        [StringLength(300, ErrorMessage = "La bio puede tener hasta 300 caracteres.")]
        [Display(Name = "Biografía")]
        public string? Biografia { get; set; }

        public string? AvatarUrl { get; set; }

        [Display(Name = "Cuenta privada")]
        public bool EsPrivada { get; set; }

        public string Inicial =>
            string.IsNullOrEmpty(NombreMostrar) ? "?" : NombreMostrar[..1].ToUpper();
    }

    // Revisa que el avatar sea una URL de DiceBear hecha con nuestro editor
    public static class AvatarValidador
    {
        private const string Prefijo = "https://api.dicebear.com/9.x/adventurer/svg?";

        private static readonly HashSet<string> ParametrosPermitidos = new()
        {
            "seed", "skinColor", "hair", "hairColor", "eyes", "eyebrows", "mouth",
            "glasses", "glassesProbability", "earrings", "earringsProbability",
            "features", "featuresProbability", "backgroundColor"
        };

        private static readonly Regex ValorSeguro = new("^[a-zA-Z0-9]{1,20}$");

        public static bool EsValido(string? url)
        {
            if (string.IsNullOrEmpty(url)) return true;
            if (url.Length > 400 || !url.StartsWith(Prefijo, StringComparison.Ordinal)) return false;

            var consulta = url.Substring(Prefijo.Length);
            foreach (var par in consulta.Split('&', StringSplitOptions.RemoveEmptyEntries))
            {
                var partes = par.Split('=', 2);
                if (partes.Length != 2
                    || !ParametrosPermitidos.Contains(partes[0])
                    || !ValorSeguro.IsMatch(partes[1]))
                {
                    return false;
                }
            }
            return true;
        }
    }
}