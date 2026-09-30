USE MapiticosDB;
GO

-- Datos actuales del perfil, para llenar el formulario
CREATE OR ALTER PROCEDURE sp_Perfil_ObtenerParaEditar
    @UsuarioId NVARCHAR(450)
AS
BEGIN
    SET NOCOUNT ON;
    SELECT
        LEFT(u.UserName, CHARINDEX('@', u.UserName + '@') - 1) AS NombreUsuario,
        ISNULL(p.NombreMostrar, LEFT(u.UserName, CHARINDEX('@', u.UserName + '@') - 1)) AS NombreMostrar,
        p.Biografia,
        p.AvatarUrl,
        ISNULL(p.EsPrivada, 0) AS EsPrivada
    FROM AspNetUsers u
    LEFT JOIN Perfiles p ON p.UsuarioId = u.Id
    WHERE u.Id = @UsuarioId;
END
GO

-- Guarda el perfil: si no existe la fila la crea, si existe la actualiza
CREATE OR ALTER PROCEDURE sp_Perfil_Guardar
    @UsuarioId      NVARCHAR(450),
    @NombreMostrar  NVARCHAR(100),
    @Biografia      NVARCHAR(300) = NULL,
    @AvatarUrl      NVARCHAR(400) = NULL,
    @EsPrivada      BIT
AS
BEGIN
    SET NOCOUNT ON;

    IF EXISTS (SELECT 1 FROM Perfiles WHERE UsuarioId = @UsuarioId)
    BEGIN
        UPDATE Perfiles
        SET NombreMostrar = @NombreMostrar,
            Biografia     = @Biografia,
            AvatarUrl     = @AvatarUrl,
            EsPrivada     = @EsPrivada
        WHERE UsuarioId = @UsuarioId;
    END
    ELSE
    BEGIN
        INSERT INTO Perfiles (UsuarioId, NombreMostrar, Biografia, AvatarUrl, EsPrivada)
        VALUES (@UsuarioId, @NombreMostrar, @Biografia, @AvatarUrl, @EsPrivada);
    END
END
GO