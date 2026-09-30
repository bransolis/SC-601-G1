using System.Data;
using Mapiticos.Models.ViewModels;
using Microsoft.Data.SqlClient;

namespace Mapiticos.Repositorios
{
    public class PerfilRepositorio : IPerfilRepositorio
    {
        private readonly string _cadenaConexion;

        public PerfilRepositorio(IConfiguration configuracion)
        {
            _cadenaConexion = configuracion.GetConnectionString("DefaultConnection")
                ?? throw new InvalidOperationException("No se encontró la cadena de conexión 'DefaultConnection'.");
        }

        // ===== Perfil completo (pantalla Perfil) =====
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

            // Resultado 1: datos del perfil
            if (!await lector.ReadAsync())
            {
                return null;
            }

            var perfil = new PerfilViewModel
            {
                NombreUsuario = lector.GetString(lector.GetOrdinal("NombreUsuario")),
                NombreMostrar = lector.GetString(lector.GetOrdinal("NombreMostrar")),
                Biografia = lector["Biografia"] as string,
                AvatarUrl = lector["AvatarUrl"] as string,
                EsPrivada = lector.GetBoolean(lector.GetOrdinal("EsPrivada")),
                CantidadSeguidores = lector.GetInt32(lector.GetOrdinal("CantidadSeguidores")),
                CantidadSiguiendo = lector.GetInt32(lector.GetOrdinal("CantidadSiguiendo"))
            };

            // Resultado 2: aventuras
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

            // Resultado 3: etiquetas
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

        // ===== Datos para el formulario de Editar perfil =====
        public async Task<EditarPerfilViewModel?> ObtenerParaEditarAsync(string usuarioId)
        {
            using var conexion = new SqlConnection(_cadenaConexion);
            using var comando = new SqlCommand("sp_Perfil_ObtenerParaEditar", conexion)
            {
                CommandType = CommandType.StoredProcedure
            };
            comando.Parameters.Add("@UsuarioId", SqlDbType.NVarChar, 450).Value = usuarioId;

            await conexion.OpenAsync();
            using var lector = await comando.ExecuteReaderAsync();

            if (!await lector.ReadAsync())
            {
                return null;
            }

            return new EditarPerfilViewModel
            {
                NombreUsuario = lector.GetString(lector.GetOrdinal("NombreUsuario")),
                NombreMostrar = lector.GetString(lector.GetOrdinal("NombreMostrar")),
                Biografia = lector["Biografia"] as string,
                AvatarUrl = lector["AvatarUrl"] as string,
                EsPrivada = lector.GetBoolean(lector.GetOrdinal("EsPrivada"))
            };
        }

        // ===== Guardar los cambios del perfil =====
        public async Task GuardarAsync(string usuarioId, EditarPerfilViewModel datos)
        {
            using var conexion = new SqlConnection(_cadenaConexion);
            using var comando = new SqlCommand("sp_Perfil_Guardar", conexion)
            {
                CommandType = CommandType.StoredProcedure
            };

            comando.Parameters.Add("@UsuarioId", SqlDbType.NVarChar, 450).Value = usuarioId;
            comando.Parameters.Add("@NombreMostrar", SqlDbType.NVarChar, 100).Value = datos.NombreMostrar.Trim();
            comando.Parameters.Add("@Biografia", SqlDbType.NVarChar, 300).Value =
                string.IsNullOrWhiteSpace(datos.Biografia) ? DBNull.Value : datos.Biografia.Trim();
            comando.Parameters.Add("@AvatarUrl", SqlDbType.NVarChar, 400).Value =
                string.IsNullOrWhiteSpace(datos.AvatarUrl) ? DBNull.Value : datos.AvatarUrl;
            comando.Parameters.Add("@EsPrivada", SqlDbType.Bit).Value = datos.EsPrivada;

            await conexion.OpenAsync();
            await comando.ExecuteNonQueryAsync();
        }
    }
}