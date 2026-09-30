using System.Data;
using Mapiticos.Models.ViewModels;
using Microsoft.Data.SqlClient;

namespace Mapiticos.Repositorios
{
    public class PerfilRepositorio : IPerfilRepositorio
    {
        private readonly string _cadenaConexion;

        // Recibe la configuración para leer la cadena de conexión de appsettings.json
        public PerfilRepositorio(IConfiguration configuracion)
        {
            _cadenaConexion = configuracion.GetConnectionString("DefaultConnection")
                ?? throw new InvalidOperationException("No se encontró la cadena de conexión 'DefaultConnection'.");
        }

        public async Task<PerfilViewModel?> ObtenerPerfilAsync(string usuarioId)
        {
            using var conexion = new SqlConnection(_cadenaConexion);
            using var comando = new SqlCommand("sp_Perfil_Obtener", conexion)
            {
                CommandType = CommandType.StoredProcedure
            };
            comando.Parameters.Add("@UsuarioId", SqlDbType.NVarChar, 450).Value = usuarioId;

            await conexion.OpenAsync();
            using var lector = await comando.ExecuteReaderAsync();

            // ===== Resultado 1: datos del perfil =====
            if (!await lector.ReadAsync())
            {
                return null; // el usuario no existe
            }

            var perfil = new PerfilViewModel
            {
                NombreUsuario = lector.GetString(lector.GetOrdinal("NombreUsuario")),
                NombreMostrar = lector.GetString(lector.GetOrdinal("NombreMostrar")),
                Biografia = lector["Biografia"] as string,   // puede venir NULL
                AvatarUrl = lector["AvatarUrl"] as string,   // puede venir NULL
                EsPrivada = lector.GetBoolean(lector.GetOrdinal("EsPrivada")),
                CantidadSeguidores = lector.GetInt32(lector.GetOrdinal("CantidadSeguidores")),
                CantidadSiguiendo = lector.GetInt32(lector.GetOrdinal("CantidadSiguiendo"))
            };

            // ===== Resultado 2: sus aventuras =====
            await lector.NextResultAsync();
            var aventurasPorId = new Dictionary<int, AventuraMiniaturaViewModel>();

            while (await lector.ReadAsync())
            {
                var aventura = new AventuraMiniaturaViewModel
                {
                    AventuraId = lector.GetInt32(lector.GetOrdinal("AventuraId")),
                    Titulo = lector.GetString(lector.GetOrdinal("Titulo")),
                    FotoUrl = lector["FotoUrl"] as string
                };
                perfil.Aventuras.Add(aventura);
                aventurasPorId[aventura.AventuraId] = aventura;
            }

            // ===== Resultado 3: etiquetas de cada aventura =====
            await lector.NextResultAsync();

            while (await lector.ReadAsync())
            {
                var aventuraId = lector.GetInt32(lector.GetOrdinal("AventuraId"));

                if (aventurasPorId.TryGetValue(aventuraId, out var aventura))
                {
                    aventura.Etiquetas.Add(new EtiquetaViewModel
                    {
                        Nombre = lector.GetString(lector.GetOrdinal("Nombre")),
                        Icono = lector.GetString(lector.GetOrdinal("Icono"))
                    });
                }
            }

            return perfil;
        }
    }
}