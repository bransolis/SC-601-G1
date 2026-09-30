/* =========================================================
   MAPITICOS - 02 DATOS DE PRUEBA
   ---------------------------------------------------------
   1. Registrate primero en la app (pagina de bienvenida).
   2. Cambia el correo de abajo por el que usaste.
   3. Ejecuta el script. Al final muestra 3 tablitas.
   Se ejecuta UNA sola vez por usuario.
   ========================================================= */

USE MapiticosDB;

DECLARE @Correo NVARCHAR(256) = 'tucorreo@ejemplo.com';   -- CAMBIA ESTO por tu correo
DECLARE @UsuarioId NVARCHAR(450) = (SELECT Id FROM AspNetUsers WHERE Email = @Correo);

IF @UsuarioId IS NULL
BEGIN
    PRINT 'No existe un usuario con ese correo. Revisa que este bien escrito.';
    RETURN;
END

-- Perfil
INSERT INTO Perfiles (UsuarioId, NombreMostrar, Biografia, EsPrivada)
VALUES (@UsuarioId, N'Explorador de prueba', N'Buscando el próximo mirador. Café en mano y botas puestas.', 1);

-- Aventuras
INSERT INTO Aventuras (UsuarioId, ProvinciaId, Titulo, Descripcion, Latitud, Longitud)
VALUES
(@UsuarioId, (SELECT ProvinciaId FROM Provincias WHERE Nombre = N'San José'), N'Cerro Chirripó', N'La cima más alta de Costa Rica.', 9.484300, -83.488900),
(@UsuarioId, (SELECT ProvinciaId FROM Provincias WHERE Nombre = N'Heredia'), N'Café en Barva', N'Parada antes de subir al volcán.', 10.100000, -84.110000),
(@UsuarioId, (SELECT ProvinciaId FROM Provincias WHERE Nombre = N'Guanacaste'), N'Playa Conchal', N'Arena de conchitas y agua clarita.', 10.400500, -85.811300),
(@UsuarioId, (SELECT ProvinciaId FROM Provincias WHERE Nombre = N'Cartago'), N'Mirador de Orosi', N'Vista a todo el valle.', 9.796000, -83.856000),
(@UsuarioId, (SELECT ProvinciaId FROM Provincias WHERE Nombre = N'San José'), N'Parque La Sabana', N'Vuelta de 5 km en la mañana.', 9.937000, -84.103000),
(@UsuarioId, (SELECT ProvinciaId FROM Provincias WHERE Nombre = N'Alajuela'), N'Río Celeste', N'El azul más increíble.', 10.707000, -84.999000);

-- Etiquetas de cada aventura (una instruccion por aventura)
INSERT INTO AventuraEtiquetas (AventuraId, EtiquetaId)
SELECT a.AventuraId, e.EtiquetaId FROM Aventuras a CROSS JOIN Etiquetas e
WHERE a.UsuarioId = @UsuarioId AND a.Titulo = N'Cerro Chirripó' AND e.Nombre IN (N'Hiking', N'Vista');

INSERT INTO AventuraEtiquetas (AventuraId, EtiquetaId)
SELECT a.AventuraId, e.EtiquetaId FROM Aventuras a CROSS JOIN Etiquetas e
WHERE a.UsuarioId = @UsuarioId AND a.Titulo = N'Café en Barva' AND e.Nombre IN (N'Café');

INSERT INTO AventuraEtiquetas (AventuraId, EtiquetaId)
SELECT a.AventuraId, e.EtiquetaId FROM Aventuras a CROSS JOIN Etiquetas e
WHERE a.UsuarioId = @UsuarioId AND a.Titulo = N'Playa Conchal' AND e.Nombre IN (N'Playa', N'Picnic');

INSERT INTO AventuraEtiquetas (AventuraId, EtiquetaId)
SELECT a.AventuraId, e.EtiquetaId FROM Aventuras a CROSS JOIN Etiquetas e
WHERE a.UsuarioId = @UsuarioId AND a.Titulo = N'Mirador de Orosi' AND e.Nombre IN (N'Vista', N'Café');

INSERT INTO AventuraEtiquetas (AventuraId, EtiquetaId)
SELECT a.AventuraId, e.EtiquetaId FROM Aventuras a CROSS JOIN Etiquetas e
WHERE a.UsuarioId = @UsuarioId AND a.Titulo = N'Parque La Sabana' AND e.Nombre IN (N'Correr');

INSERT INTO AventuraEtiquetas (AventuraId, EtiquetaId)
SELECT a.AventuraId, e.EtiquetaId FROM Aventuras a CROSS JOIN Etiquetas e
WHERE a.UsuarioId = @UsuarioId AND a.Titulo = N'Río Celeste' AND e.Nombre IN (N'Hiking');

-- Probar el SP
EXEC sp_Perfil_Obtener @UsuarioId;
