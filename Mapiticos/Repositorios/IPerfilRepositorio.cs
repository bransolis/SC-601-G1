using Mapiticos.Models.ViewModels;

namespace Mapiticos.Repositorios
{
    // El "contrato": qué puede hacer el repositorio de perfiles.
    // El controlador solo conoce esto, no cómo se hace por dentro.
    public interface IPerfilRepositorio
    {
        Task<PerfilViewModel?> ObtenerPerfilAsync(string usuarioId);
    }
}