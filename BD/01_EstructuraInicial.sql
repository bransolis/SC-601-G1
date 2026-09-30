/* =====================================================================
   MAPITICOS - 01 ESTRUCTURA
   ---------------------------------------------------------------------
  
   ===================================================================== */

USE MapiticosDB;
GO

/* =====================================================================
   1. CATALOGOS
   ===================================================================== */
IF OBJECT_ID('dbo.Provincias', 'U') IS NULL
BEGIN
    CREATE TABLE Provincias (
        ProvinciaId  INT IDENTITY(1,1) PRIMARY KEY,
        Nombre       NVARCHAR(50) NOT NULL UNIQUE
    );
END
GO

IF OBJECT_ID('dbo.Etiquetas', 'U') IS NULL
BEGIN
    CREATE TABLE Etiquetas (
        EtiquetaId  INT IDENTITY(1,1) PRIMARY KEY,
        Nombre      NVARCHAR(50) NOT NULL UNIQUE,
        Icono       NVARCHAR(50) NOT NULL          
    );
END
GO

/* =====================================================================
   2. PERFILES (se conecta con AspNetUsers de Identity)
   ===================================================================== */
IF OBJECT_ID('dbo.Perfiles', 'U') IS NULL
BEGIN
    CREATE TABLE Perfiles (
        UsuarioId      NVARCHAR(450) NOT NULL PRIMARY KEY
                       CONSTRAINT FK_Perfiles_Usuarios REFERENCES AspNetUsers(Id) ON DELETE CASCADE,
        NombreUsuario  NVARCHAR(30)  NULL,          -- el @usuario (unico)
        NombreMostrar  NVARCHAR(100) NOT NULL,
        Biografia      NVARCHAR(300) NULL,
        AvatarUrl      NVARCHAR(400) NULL,
        EsPrivada      BIT NOT NULL CONSTRAINT DF_Perfiles_EsPrivada DEFAULT 0,
        FechaCreacion  DATETIME2 NOT NULL CONSTRAINT DF_Perfiles_Fecha DEFAULT SYSDATETIME()
    );
END
GO

-- Si la base es de una version anterior, agrega la columna del @usuario
IF COL_LENGTH('dbo.Perfiles', 'NombreUsuario') IS NULL
BEGIN
    ALTER TABLE Perfiles ADD NombreUsuario NVARCHAR(30) NULL;
END
GO

-- @usuario unico, pero permite varios NULL (quien aun no lo elige)
IF NOT EXISTS (SELECT 1 FROM sys.indexes
               WHERE name = 'UX_Perfiles_NombreUsuario' AND object_id = OBJECT_ID('dbo.Perfiles'))
BEGIN
    CREATE UNIQUE INDEX UX_Perfiles_NombreUsuario
        ON Perfiles(NombreUsuario)
        WHERE NombreUsuario IS NOT NULL;
END
GO

/* =====================================================================
   3. AVENTURAS (cada pin del mapa)
   ===================================================================== */
IF OBJECT_ID('dbo.Aventuras', 'U') IS NULL
BEGIN
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
END
GO

-- Una aventura puede tener VARIAS etiquetas (Hiking + Vista...)
IF OBJECT_ID('dbo.AventuraEtiquetas', 'U') IS NULL
BEGIN
    CREATE TABLE AventuraEtiquetas (
        AventuraId  INT NOT NULL CONSTRAINT FK_AvEt_Aventuras REFERENCES Aventuras(AventuraId) ON DELETE CASCADE,
        EtiquetaId  INT NOT NULL CONSTRAINT FK_AvEt_Etiquetas REFERENCES Etiquetas(EtiquetaId),
        CONSTRAINT PK_AventuraEtiquetas PRIMARY KEY (AventuraId, EtiquetaId)
    );
END
GO

IF OBJECT_ID('dbo.FotosAventura', 'U') IS NULL
BEGIN
    CREATE TABLE FotosAventura (
        FotoId      INT IDENTITY(1,1) PRIMARY KEY,
        AventuraId  INT NOT NULL CONSTRAINT FK_Fotos_Aventuras REFERENCES Aventuras(AventuraId) ON DELETE CASCADE,
        Url         NVARCHAR(400) NOT NULL,
        Orden       INT NOT NULL CONSTRAINT DF_Fotos_Orden DEFAULT 1
    );
END
GO

/* =====================================================================
   4. SOCIAL
   ===================================================================== */
IF OBJECT_ID('dbo.Seguimientos', 'U') IS NULL
BEGIN
    CREATE TABLE Seguimientos (
        SeguidorId      NVARCHAR(450) NOT NULL CONSTRAINT FK_Seg_Seguidor REFERENCES AspNetUsers(Id),
        SeguidoId       NVARCHAR(450) NOT NULL CONSTRAINT FK_Seg_Seguido  REFERENCES AspNetUsers(Id),
        Estado          NVARCHAR(20)  NOT NULL CONSTRAINT DF_Seg_Estado DEFAULT 'Aceptado',
        FechaSolicitud  DATETIME2 NOT NULL CONSTRAINT DF_Seg_Fecha DEFAULT SYSDATETIME(),
        CONSTRAINT PK_Seguimientos PRIMARY KEY (SeguidorId, SeguidoId),
        CONSTRAINT CK_Seg_NoASiMismo CHECK (SeguidorId <> SeguidoId),
        CONSTRAINT CK_Seg_Estado CHECK (Estado IN ('Pendiente', 'Aceptado'))
    );
END
GO

IF OBJECT_ID('dbo.Likes', 'U') IS NULL
BEGIN
    CREATE TABLE Likes (
        UsuarioId   NVARCHAR(450) NOT NULL CONSTRAINT FK_Likes_Usuarios REFERENCES AspNetUsers(Id),
        AventuraId  INT NOT NULL CONSTRAINT FK_Likes_Aventuras REFERENCES Aventuras(AventuraId) ON DELETE CASCADE,
        Fecha       DATETIME2 NOT NULL CONSTRAINT DF_Likes_Fecha DEFAULT SYSDATETIME(),
        CONSTRAINT PK_Likes PRIMARY KEY (UsuarioId, AventuraId)
    );
END
GO

IF OBJECT_ID('dbo.Comentarios', 'U') IS NULL
BEGIN
    CREATE TABLE Comentarios (
        ComentarioId  INT IDENTITY(1,1) PRIMARY KEY,
        AventuraId    INT NOT NULL CONSTRAINT FK_Com_Aventuras REFERENCES Aventuras(AventuraId) ON DELETE CASCADE,
        UsuarioId     NVARCHAR(450) NOT NULL CONSTRAINT FK_Com_Usuarios REFERENCES AspNetUsers(Id),
        Texto         NVARCHAR(500) NOT NULL,
        Fecha         DATETIME2 NOT NULL CONSTRAINT DF_Com_Fecha DEFAULT SYSDATETIME()
    );
END
GO

-- Checklist: "Quiero ir" / "Ya fui"
IF OBJECT_ID('dbo.Favoritos', 'U') IS NULL
BEGIN
    CREATE TABLE Favoritos (
        UsuarioId      NVARCHAR(450) NOT NULL CONSTRAINT FK_Fav_Usuarios REFERENCES AspNetUsers(Id),
        AventuraId     INT NOT NULL CONSTRAINT FK_Fav_Aventuras REFERENCES Aventuras(AventuraId) ON DELETE CASCADE,
        Estado         NVARCHAR(20) NOT NULL CONSTRAINT DF_Fav_Estado DEFAULT 'QuieroIr',
        FechaAgregado  DATETIME2 NOT NULL CONSTRAINT DF_Fav_Fecha DEFAULT SYSDATETIME(),
        FechaVisitado  DATETIME2 NULL,
        CONSTRAINT PK_Favoritos PRIMARY KEY (UsuarioId, AventuraId),
        CONSTRAINT CK_Fav_Estado CHECK (Estado IN ('QuieroIr', 'Visitado'))
    );
END
GO

-- Publicaciones de otros que el usuario oculto de su feed
IF OBJECT_ID('dbo.FeedOcultos', 'U') IS NULL
BEGIN
    CREATE TABLE FeedOcultos (
        UsuarioId   NVARCHAR(450) NOT NULL CONSTRAINT FK_Ocu_Usuarios REFERENCES AspNetUsers(Id),
        AventuraId  INT NOT NULL CONSTRAINT FK_Ocu_Aventuras REFERENCES Aventuras(AventuraId) ON DELETE CASCADE,
        CONSTRAINT PK_FeedOcultos PRIMARY KEY (UsuarioId, AventuraId)
    );
END
GO

IF OBJECT_ID('dbo.Notificaciones', 'U') IS NULL
BEGIN
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
END
GO

/* =====================================================================
   5. INDICES
   ===================================================================== */
IF NOT EXISTS (SELECT 1 FROM sys.indexes
               WHERE name = 'IX_Aventuras_Usuario' AND object_id = OBJECT_ID('dbo.Aventuras'))
    CREATE INDEX IX_Aventuras_Usuario ON Aventuras(UsuarioId);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes
               WHERE name = 'IX_Notificaciones_Destino' AND object_id = OBJECT_ID('dbo.Notificaciones'))
    CREATE INDEX IX_Notificaciones_Destino ON Notificaciones(UsuarioDestinoId, Leida);
GO

/* =====================================================================
   6. DATOS INICIALES (no se duplican)
   ===================================================================== */
INSERT INTO Provincias (Nombre)
SELECT v.Nombre
FROM (VALUES (N'San José'), (N'Alajuela'), (N'Cartago'), (N'Heredia'),
             (N'Guanacaste'), (N'Puntarenas'), (N'Limón')) AS v(Nombre)
WHERE NOT EXISTS (SELECT 1 FROM Provincias p WHERE p.Nombre = v.Nombre);
GO

INSERT INTO Etiquetas (Nombre, Icono)
SELECT v.Nombre, v.Icono
FROM (VALUES (N'Hiking',  'ti-mountain'),
             (N'Café',    'ti-coffee'),
             (N'Picnic',  'ti-basket'),
             (N'Vista',   'ti-sunset'),
             (N'Correr',  'ti-run'),
             (N'Playa',   'ti-beach'),
             (N'Comida',  'ti-tools-kitchen-2'),
             (N'Cultura', 'ti-building-bank')) AS v(Nombre, Icono)
WHERE NOT EXISTS (SELECT 1 FROM Etiquetas e WHERE e.Nombre = v.Nombre);
GO

/* =====================================================================
   7. ROLES (la app tambien los crea al arrancar; aqui por si acaso)
   ===================================================================== */
INSERT INTO AspNetRoles (Id, Name, NormalizedName, ConcurrencyStamp)
SELECT CONVERT(NVARCHAR(450), NEWID()), v.Nombre, UPPER(v.Nombre), CONVERT(NVARCHAR(450), NEWID())
FROM (VALUES (N'Usuario'), (N'Admin')) AS v(Nombre)
WHERE NOT EXISTS (SELECT 1 FROM AspNetRoles r WHERE r.NormalizedName = UPPER(v.Nombre));
GO

PRINT '01_Estructura listo.';
GO
