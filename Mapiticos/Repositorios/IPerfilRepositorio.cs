using Mapiticos.Models.ViewModels;

namespace Mapiticos.Repositorios
{
    public interface IPerfilRepositorio
    {
        Task<PerfilViewModel?> ObtenerPerfilAsync(string usuarioId);
        Task<EditarPerfilViewModel?> ObtenerParaEditarAsync(string usuarioId);
        Task GuardarAsync(string usuarioId, EditarPerfilViewModel datos);
    }
}