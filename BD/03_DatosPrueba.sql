/* =====================================================================
   MAPITICOS - 03 DATOS DE PRUEBA
 
   ===================================================================== */

USE MapiticosDB;
GO

/* =====================================================================
   USUARIO DE PRUEBA + DATOS DE EJEMPLO
      Correo: prueba@gmail.com   Contrasena: Prueba123!   @usuario: prueba
   ===================================================================== */
DECLARE @Correo NVARCHAR(256) = N'prueba@gmail.com';
DECLARE @UsuarioId NVARCHAR(450) = (SELECT Id FROM AspNetUsers WHERE NormalizedUserName = UPPER(@Correo));

-- 9.1 Crear la cuenta en Identity (la contrasena va cifrada, igual que la guarda la app)
IF @UsuarioId IS NULL
BEGIN
    SET @UsuarioId = N'd35614d6-b823-4bd5-95a0-fded8e6e7da8';

    INSERT INTO AspNetUsers
        (Id, UserName, NormalizedUserName, Email, NormalizedEmail, EmailConfirmed,
         PasswordHash, SecurityStamp, ConcurrencyStamp,
         PhoneNumber, PhoneNumberConfirmed, TwoFactorEnabled, LockoutEnd, LockoutEnabled, AccessFailedCount)
    VALUES
        (@UsuarioId, @Correo, UPPER(@Correo), @Correo, UPPER(@Correo), 1,
         N'AQAAAAIAAYagAAAAEO5uANFlhj7W/6+hF1InfTWYIzjWA6b/H8igD3vE1pr7rswAJmDA6dOSzgVqcbQxbg==',
         N'D900D46CD7134C3FB991A641A6FE4029',
         N'ac0e064a-2b6a-4dc2-8275-40a42e4176d0',
         NULL, 0, 0, NULL, 1, 0);
END

-- 9.2 Rol "Usuario"
INSERT INTO AspNetUserRoles (UserId, RoleId)
SELECT @UsuarioId, r.Id
FROM AspNetRoles r
WHERE r.NormalizedName = N'USUARIO'
  AND NOT EXISTS (SELECT 1 FROM AspNetUserRoles ur WHERE ur.UserId = @UsuarioId AND ur.RoleId = r.Id);

-- 9.3 Perfil con @usuario "prueba"
IF NOT EXISTS (SELECT 1 FROM Perfiles WHERE UsuarioId = @UsuarioId)
BEGIN
    INSERT INTO Perfiles (UsuarioId, NombreUsuario, NombreMostrar, Biografia, EsPrivada)
    VALUES (@UsuarioId,
            CASE WHEN EXISTS (SELECT 1 FROM Perfiles WHERE NombreUsuario = N'prueba') THEN NULL ELSE N'prueba' END,
            N'Explorador de prueba',
            N'Buscando el próximo mirador. Café en mano y botas puestas.',
            0);
END
ELSE IF (SELECT NombreUsuario FROM Perfiles WHERE UsuarioId = @UsuarioId) IS NULL
     AND NOT EXISTS (SELECT 1 FROM Perfiles WHERE NombreUsuario = N'prueba')
BEGIN
    UPDATE Perfiles SET NombreUsuario = N'prueba' WHERE UsuarioId = @UsuarioId;
END

-- 9.4 Aventuras de ejemplo (solo si todavia no tiene)
IF NOT EXISTS (SELECT 1 FROM Aventuras WHERE UsuarioId = @UsuarioId)
BEGIN
    INSERT INTO Aventuras (UsuarioId, ProvinciaId, Titulo, Descripcion, Latitud, Longitud)
    VALUES
    (@UsuarioId, (SELECT ProvinciaId FROM Provincias WHERE Nombre = N'San José'),   N'Cerro Chirripó',   N'La cima más alta de Costa Rica.',     9.484300, -83.488900),
    (@UsuarioId, (SELECT ProvinciaId FROM Provincias WHERE Nombre = N'Heredia'),    N'Café en Barva',    N'Parada antes de subir al volcán.',   10.100000, -84.110000),
    (@UsuarioId, (SELECT ProvinciaId FROM Provincias WHERE Nombre = N'Guanacaste'), N'Playa Conchal',    N'Arena de conchitas y agua clarita.', 10.400500, -85.811300),
    (@UsuarioId, (SELECT ProvinciaId FROM Provincias WHERE Nombre = N'Cartago'),    N'Mirador de Orosi', N'Vista a todo el valle.',              9.796000, -83.856000),
    (@UsuarioId, (SELECT ProvinciaId FROM Provincias WHERE Nombre = N'San José'),   N'Parque La Sabana', N'Vuelta de 5 km en la mañana.',        9.937000, -84.103000),
    (@UsuarioId, (SELECT ProvinciaId FROM Provincias WHERE Nombre = N'Alajuela'),   N'Río Celeste',      N'El azul más increíble.',             10.707000, -84.999000);

    -- Etiquetas de cada aventura
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
END

PRINT 'MapiticosDB lista. Usuario de prueba: prueba@gmail.com / Prueba123!';
GO
