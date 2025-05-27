DROP DATABASE IF EXISTS tienda_en_linea;
CREATE DATABASE tienda_en_linea;
USE tienda_en_linea;

CREATE TABLE usuario (
    idUsuario INT AUTO_INCREMENT PRIMARY KEY,
    correoElectronico VARCHAR(100) NOT NULL UNIQUE,
    contrasena VARCHAR(255) NOT NULL,
    fechaCreacion DATETIME DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE tipoIdentificacion (
    idTipoIdentificacion INT AUTO_INCREMENT PRIMARY KEY,
    tipoIdentificacion VARCHAR(50)
);

CREATE TABLE persona (
    idPersona INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(50) NOT NULL,
    apellido VARCHAR(50) NOT NULL,
    numeroTelefono VARCHAR(10) NOT NULL,
    numeroIdentificacion VARCHAR(15) NOT NULL,
    idUsuario INT NOT NULL,
    idTipoIdentificacion INT NOT NULL,
    FOREIGN KEY (idTipoIdentificacion) REFERENCES tipoIdentificacion(idTipoIdentificacion),
    FOREIGN KEY (idUsuario) REFERENCES usuario(idUsuario),
    fechaCreacion DATETIME DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE rol (
    idRol INT AUTO_INCREMENT PRIMARY KEY,
    rol VARCHAR(10),
    fechaCreacion DATETIME DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE usuarioRol (
    idUsuarioRol INT AUTO_INCREMENT PRIMARY KEY,
    idRol INT NOT NULL,
    idUsuario INT NOT NULL,
    FOREIGN KEY (idUsuario) REFERENCES usuario(idUsuario),
    FOREIGN KEY (idRol) REFERENCES rol(idRol),
    fechaCreacion DATETIME DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE categoria (
    idCategoria INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    fechaCreacion DATETIME DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE producto (
    idProducto INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(150) NOT NULL,
    descripcion TEXT,
    idCategoria INT,
    inventario INT DEFAULT 0,
    fechaCreacion DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (idCategoria) REFERENCES categoria(idCategoria)
);

CREATE TABLE pedido (
    idPedido INT AUTO_INCREMENT PRIMARY KEY,
    idUsuario INT NOT NULL,
    total DECIMAL(10,2) NOT NULL,
    estado ENUM('PENDIENTE', 'PAGADO', 'ENVIADO', 'CANCELADO') DEFAULT 'PENDIENTE',
    fechaCreacion DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (idUsuario) REFERENCES usuario(idUsuario)
);

CREATE TABLE varianteProducto (
    idVarianteProducto INT AUTO_INCREMENT PRIMARY KEY,
    idProducto INT NOT NULL,
    talla VARCHAR(15),
    color VARCHAR(50),
    inventario INT DEFAULT 0,
    precio DECIMAL(10,2) NOT NULL,
    urlImagen VARCHAR(255),
    FOREIGN KEY (idProducto) REFERENCES producto(idProducto),
    fechaCreacion DATETIME DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE detallePedido (
    idDetallePedido INT AUTO_INCREMENT PRIMARY KEY,
    idPedido INT NOT NULL,
    idVarianteProducto INT NOT NULL,
    cantidad INT NOT NULL,
    precioUnitario DECIMAL(10,2) NOT NULL,
    FOREIGN KEY (idPedido) REFERENCES pedido(idPedido),
    FOREIGN KEY (idVarianteProducto) REFERENCES varianteProducto(idVarianteProducto),
    fechaCreacion DATETIME DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE carrito (
    idCarrito INT AUTO_INCREMENT PRIMARY KEY,
    idUsuario INT NOT NULL,
    idVarianteProducto INT NOT NULL,
    cantidad INT NOT NULL,
    FOREIGN KEY (idUsuario) REFERENCES usuario(idUsuario),
    FOREIGN KEY (idVarianteProducto) REFERENCES varianteProducto(idVarianteProducto),
    fechaCreacion DATETIME DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE pago (
    idPago INT AUTO_INCREMENT PRIMARY KEY,
    idPedido INT NOT NULL,
    metodo VARCHAR(50) NOT NULL,
    monto DECIMAL(10,2) NOT NULL,
    estado ENUM('PENDIENTE', 'COMPLETADO', 'FALLIDO') DEFAULT 'PENDIENTE',
    fechaCreacion DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (idPedido) REFERENCES pedido(idPedido)
);

CREATE TABLE envio (
    idEnvio INT AUTO_INCREMENT PRIMARY KEY,
    idPedido INT NOT NULL,
    direccion TEXT NOT NULL,
    ciudad VARCHAR(100) NOT NULL,
    pais VARCHAR(100) NOT NULL,
    codigoPostal VARCHAR(20) NOT NULL,
    fechaCreacion DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (idPedido) REFERENCES pedido(idPedido)
);

