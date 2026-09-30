using System.ComponentModel.DataAnnotations;

namespace Mapiticos.Models.ViewModels
{
    public class RegistroViewModel
    {
        [Required(ErrorMessage = "Escribí tu correo.")]
        [EmailAddress(ErrorMessage = "Ese correo no parece válido.")]
        [Display(Name = "Correo electrónico")]
        public string Correo { get; set; } = "";

        [Required(ErrorMessage = "Elegí un nombre de usuario.")]
        [RegularExpression(ReglasNombreUsuario.Patron, ErrorMessage = ReglasNombreUsuario.MensajeFormato)]
        [Display(Name = "Nombre de usuario")]
        public string NombreUsuario { get; set; } = "";

        [Required(ErrorMessage = "Escribí una contraseña.")]
        [DataType(DataType.Password)]
        [Display(Name = "Contraseña")]
        public string Clave { get; set; } = "";

        [Required(ErrorMessage = "Confirmá la contraseña.")]
        [DataType(DataType.Password)]
        [Compare(nameof(Clave), ErrorMessage = "Las contraseñas no coinciden.")]
        [Display(Name = "Confirmá la contraseña")]
        public string ConfirmarClave { get; set; } = "";
    }
}