namespace Mapiticos.Models.ViewModels
{
  
    public class AventuraMiniaturaViewModel
    {
        public int AventuraId { get; set; }
        public string Titulo { get; set; } = "";
        public string? FotoUrl { get; set; }
        public List<EtiquetaViewModel> Etiquetas { get; set; } = new();
    }

    // Todo lo que la vista del perfil necesita
    public class PerfilViewModel
    {
        public string NombreUsuario { get; set; } = "";
        public string NombreMostrar { get; set; } = "";
        public string? Biografia { get; set; }
        public string? AvatarUrl { get; set; }
        public bool EsPrivada { get; set; }
        public int CantidadSeguidores { get; set; }
        public int CantidadSiguiendo { get; set; }
        public List<AventuraMiniaturaViewModel> Aventuras { get; set; } = new();

        public int CantidadAventuras => Aventuras.Count;

        public string Inicial =>
            string.IsNullOrEmpty(NombreMostrar) ? "?" : NombreMostrar[..1].ToUpper();
    }
}