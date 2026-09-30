/* =========================================================
   MAPITICOS - 01 ESTRUCTURA COMPLETA
   ---------------------------------------------------------
   Ejecutar DESPUES de "Update-Database" en Visual Studio
   (necesita que ya existan las tablas AspNet... de Identity).
   Se ejecuta UNA sola vez por computadora.
   ========================================================= */

USE MapiticosDB;
GO

/* =========================================================
   CATALOGOS
   ========================================================= */
CREATE TABLE Provincias (
    ProvinciaId  INT IDENTITY(1,1) PRIMARY KEY,
    Nombre       NVARCHAR(50) NOT NULL UNIQUE
);

CREATE TABLE Etiquetas (
    EtiquetaId  INT IDENTITY(1,1) PRIMARY KEY,
    Nombre      NVARCHAR(50) NOT NULL UNIQUE,
    Icono       NVARCHAR(50) NOT NULL          -- clase de Tabler Icons, ej: ti-mountain
);

/* =========================================================
   PERFILES (se conecta con AspNetUsers de Identity)
   ========================================================= */
CREATE TABLE Perfiles (
    UsuarioId      NVARCHAR(450) NOT NULL PRIMARY KEY
                   CONSTRAINT FK_Perfiles_Usuarios REFERENCES AspNetUsers(Id) ON DELETE CASCADE,
    NombreMostrar  NVARCHAR(100) NOT NULL,
    Biografia      NVARCHAR(300) NULL,
    AvatarUrl      NVARCHAR(400) NULL,
    EsPrivada      BIT NOT NULL CONSTRAINT DF_Perfiles_EsPrivada DEFAULT 0,
    FechaCreacion  DATETIME2 NOT NULL CONSTRAINT DF_Perfiles_Fecha DEFAULT SYSDATETIME()
);

/* =========================================================
   AVENTURAS (cada pin del mapa)
   ========================================================= */
CREATE TABLE Aventuras (
    AventuraId        INT IDENTITY(1,1) PRIMARY KEY,
    UsuarioId         NVARCHAR(450) NOT NULL
                      CONSTRAINT FK_Aventuras_Usuarios REFERENCES AspNetUsers(Id) ON DELETE CASCADE,
    ProvinciaId       INT NOT NULL
                      CONSTRAINT FK_Aventuras_Provincias REFERENCES Provincias(ProvinciaId),
    Titulo            NVARCHAR(100) NOT NULL,
    Descripcion       NVARCHAR(1000) NULL,
    Latitud           DECIMAL(9,6) NOT NULL,
    Longitud          DECIMAL(9,6) NOT NULL,
    EsPublica         BIT NOT NULL CONSTRAINT DF_Aventuras_EsPublica DEFAULT 1,   -- 0 = "Solo yo"
    Archivada         BIT NOT NULL CONSTRAINT DF_Aventuras_Archivada DEFAULT 0,   -- oculta del perfil sin borrarla
    FechaPublicacion  DATETIME2 NOT NULL CONSTRAINT DF_Aventuras_Fecha DEFAULT SYSDATETIME()
);

-- Una aventura puede tener VARIAS etiquetas (Hiking + Vista...)
CREATE TABLE AventuraEtiquetas (
    AventuraId  INT NOT NULL CONSTRAINT FK_AvEt_Aventuras REFERENCES Aventuras(AventuraId) ON DELETE CASCADE,
    EtiquetaId  INT NOT NULL CONSTRAINT FK_AvEt_Etiquetas REFERENCES Etiquetas(EtiquetaId),
    CONSTRAINT PK_AventuraEtiquetas PRIMARY KEY (AventuraId, EtiquetaId)
);

CREATE TABLE FotosAventura (
    FotoId      INT IDENTITY(1,1) PRIMARY KEY,
    AventuraId  INT NOT NULL CONSTRAINT FK_Fotos_Aventuras REFERENCES Aventuras(AventuraId) ON DELETE CASCADE,
    Url         NVARCHAR(400) NOT NULL,
    Orden       INT NOT NULL CONSTRAINT DF_Fotos_Orden DEFAULT 1
);

/* =========================================================
   SOCIAL
   ========================================================= */
CREATE TABLE Seguimientos (
    SeguidorId      NVARCHAR(450) NOT NULL CONSTRAINT FK_Seg_Seguidor REFERENCES AspNetUsers(Id),
    SeguidoId       NVARCHAR(450) NOT NULL CONSTRAINT FK_Seg_Seguido  REFERENCES AspNetUsers(Id),
    Estado          NVARCHAR(20)  NOT NULL CONSTRAINT DF_Seg_Estado DEFAULT 'Aceptado',
    FechaSolicitud  DATETIME2 NOT NULL CONSTRAINT DF_Seg_Fecha DEFAULT SYSDATETIME(),
    CONSTRAINT PK_Seguimientos PRIMARY KEY (SeguidorId, SeguidoId),
    CONSTRAINT CK_Seg_NoASiMismo CHECK (SeguidorId <> SeguidoId),
    CONSTRAINT CK_Seg_Estado CHECK (Estado IN ('Pendiente', 'Aceptado'))
);

CREATE TABLE Likes (
    UsuarioId   NVARCHAR(450) NOT NULL CONSTRAINT FK_Likes_Usuarios REFERENCES AspNetUsers(Id),
    AventuraId  INT NOT NULL CONSTRAINT FK_Likes_Aventuras REFERENCES Aventuras(AventuraId) ON DELETE CASCADE,
    Fecha       DATETIME2 NOT NULL CONSTRAINT DF_Likes_Fecha DEFAULT SYSDATETIME(),
    CONSTRAINT PK_Likes PRIMARY KEY (UsuarioId, AventuraId)
);

CREATE TABLE Comentarios (
    ComentarioId  INT IDENTITY(1,1) PRIMARY KEY,
    AventuraId    INT NOT NULL CONSTRAINT FK_Com_Aventuras REFERENCES Aventuras(AventuraId) ON DELETE CASCADE,
    UsuarioId     NVARCHAR(450) NOT NULL CONSTRAINT FK_Com_Usuarios REFERENCES AspNetUsers(Id),
    Texto         NVARCHAR(500) NOT NULL,
    Fecha         DATETIME2 NOT NULL CONSTRAINT DF_Com_Fecha DEFAULT SYSDATETIME()
);

-- Checklist: "Quiero ir" / "Ya fui"
CREATE TABLE Favoritos (
    UsuarioId      NVARCHAR(450) NOT NULL CONSTRAINT FK_Fav_Usuarios REFERENCES AspNetUsers(Id),
    AventuraId     INT NOT NULL CONSTRAINT FK_Fav_Aventuras REFERENCES Aventuras(AventuraId) ON DELETE CASCADE,
    Estado         NVARCHAR(20) NOT NULL CONSTRAINT DF_Fav_Estado DEFAULT 'QuieroIr',
    FechaAgregado  DATETIME2 NOT NULL CONSTRAINT DF_Fav_Fecha DEFAULT SYSDATETIME(),
    FechaVisitado  DATETIME2 NULL,
    CONSTRAINT PK_Favoritos PRIMARY KEY (UsuarioId, AventuraId),
    CONSTRAINT CK_Fav_Estado CHECK (Estado IN ('QuieroIr', 'Visitado'))
);

-- Publicaciones de otros que el usuario oculto de su feed
CREATE TABLE FeedOcultos (
    UsuarioId   NVARCHAR(450) NOT NULL CONSTRAINT FK_Ocu_Usuarios REFERENCES AspNetUsers(Id),
    AventuraId  INT NOT NULL CONSTRAINT FK_Ocu_Aventuras REFERENCES Aventuras(AventuraId) ON DELETE CASCADE,
    CONSTRAINT PK_FeedOcultos PRIMARY KEY (UsuarioId, AventuraId)
);

CREATE TABLE Notificaciones (
    NotificacionId    INT IDENTITY(1,1) PRIMARY KEY,
    UsuarioDestinoId  NVARCHAR(450) NOT NULL CONSTRAINT FK_Not_Destino REFERENCES AspNetUsers(Id),
    UsuarioOrigenId   NVARCHAR(450) NOT NULL CONSTRAINT FK_Not_Origen  REFERENCES AspNetUsers(Id),
    Tipo              NVARCHAR(30) NOT NULL,
    AventuraId        INT NULL CONSTRAINT FK_Not_Aventuras REFERENCES Aventuras(AventuraId) ON DELETE CASCADE,
    Leida             BIT NOT NULL CONSTRAINT DF_Not_Leida DEFAULT 0,
    Fecha             DATETIME2 NOT NULL CONSTRAINT DF_Not_Fecha DEFAULT SYSDATETIME(),
    CONSTRAINT CK_Not_Tipo CHECK (Tipo IN ('Like', 'Comentario', 'SolicitudSeguimiento',
                                           'SolicitudAceptada', 'NuevoSeguidor', 'NuevaAventura'))
);

-- Indices para las busquedas mas comunes
CREATE INDEX IX_Aventuras_Usuario ON Aventuras(UsuarioId);
CREATE INDEX IX_Notificaciones_Destino ON Notificaciones(UsuarioDestinoId, Leida);
GO

/* =========================================================
   DATOS INICIALES
   ========================================================= */
INSERT INTO Provincias (Nombre) VALUES
(N'San José'), (N'Alajuela'), (N'Cartago'), (N'Heredia'),
(N'Guanacaste'), (N'Puntarenas'), (N'Limón');

INSERT INTO Etiquetas (Nombre, Icono) VALUES
(N'Hiking',  'ti-mountain'),
(N'Café',    'ti-coffee'),
(N'Picnic',  'ti-basket'),
(N'Vista',   'ti-sunset'),
(N'Correr',  'ti-run'),
(N'Playa',   'ti-beach'),
(N'Comida',  'ti-tools-kitchen-2'),
(N'Cultura', 'ti-building-bank');
GO

/* =========================================================
   STORED PROCEDURES
   ========================================================= */

-- Catalogo de etiquetas (para filtros del mapa y al crear aventuras)
CREATE OR ALTER PROCEDURE sp_Etiquetas_Listar
AS
BEGIN
    SET NOCOUNT ON;
    SELECT EtiquetaId, Nombre, Icono FROM Etiquetas ORDER BY Nombre;
END
GO

-- Perfil completo: devuelve 3 resultados en una sola llamada
CREATE OR ALTER PROCEDURE sp_Perfil_Obtener
    @UsuarioId NVARCHAR(450)
AS
BEGIN
    SET NOCOUNT ON;

    -- 1) Datos del perfil + contadores.
    --    Si el usuario aun no tiene fila en Perfiles, usa lo que va antes del @ del correo.
    SELECT
        LEFT(u.UserName, CHARINDEX('@', u.UserName + '@') - 1) AS NombreUsuario,
        ISNULL(p.NombreMostrar, LEFT(u.UserName, CHARINDEX('@', u.UserName + '@') - 1)) AS NombreMostrar,
        p.Biografia,
        p.AvatarUrl,
        ISNULL(p.EsPrivada, 0) AS EsPrivada,
        (SELECT COUNT(*) FROM Seguimientos s WHERE s.SeguidoId  = u.Id AND s.Estado = 'Aceptado') AS CantidadSeguidores,
        (SELECT COUNT(*) FROM Seguimientos s WHERE s.SeguidorId = u.Id AND s.Estado = 'Aceptado') AS CantidadSiguiendo
    FROM AspNetUsers u
    LEFT JOIN Perfiles p ON p.UsuarioId = u.Id
    WHERE u.Id = @UsuarioId;

    -- 2) Sus aventuras (no archivadas), con la primera foto
    SELECT
        a.AventuraId,
        a.Titulo,
        (SELECT TOP 1 f.Url FROM FotosAventura f
          WHERE f.AventuraId = a.AventuraId ORDER BY f.Orden) AS FotoUrl
    FROM Aventuras a
    WHERE a.UsuarioId = @UsuarioId AND a.Archivada = 0
    ORDER BY a.FechaPublicacion DESC;

    -- 3) Las etiquetas de esas aventuras
    SELECT ae.AventuraId, e.Nombre, e.Icono
    FROM AventuraEtiquetas ae
    JOIN Etiquetas e ON e.EtiquetaId = ae.EtiquetaId
    JOIN Aventuras a ON a.AventuraId = ae.AventuraId
    WHERE a.UsuarioId = @UsuarioId AND a.Archivada = 0
    ORDER BY e.Nombre;
END
GO
