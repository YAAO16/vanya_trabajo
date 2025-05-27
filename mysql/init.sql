DROP DATABASE IF EXISTS tienda_online;
CREATE DATABASE tienda_online;
USE tienda_online;

CREATE TABLE usuario (
    id_usuario INT AUTO_INCREMENT PRIMARY KEY,
    email VARCHAR(100) NOT NULL UNIQUE,
    contrasena VARCHAR(255) NOT NULL,
    creado_en DATETIME DEFAULT CURRENT_TIMESTAMP,
    actualizado_en DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    activo BOOLEAN DEFAULT TRUE
);

CREATE TABLE tipo_identificacion (
    id_tipo_identificacion INT AUTO_INCREMENT PRIMARY KEY,
    nombre_tipo VARCHAR(50) NOT NULL UNIQUE
);

CREATE TABLE persona (
    id_persona INT AUTO_INCREMENT PRIMARY KEY,
    id_usuario INT NOT NULL,
    nombre VARCHAR(50) NOT NULL,
    apellido VARCHAR(50) NOT NULL,
    telefono VARCHAR(20) NOT NULL,
    numero_identificacion VARCHAR(20) NOT NULL UNIQUE,
    id_tipo_identificacion INT NOT NULL,
    creado_en DATETIME DEFAULT CURRENT_TIMESTAMP,
    actualizado_en DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (id_usuario) REFERENCES usuario(id_usuario) ON DELETE CASCADE,
    FOREIGN KEY (id_tipo_identificacion) REFERENCES tipo_identificacion(id_tipo_identificacion)
);

CREATE TABLE rol (
    id_rol INT AUTO_INCREMENT PRIMARY KEY,
    nombre_rol VARCHAR(20) NOT NULL UNIQUE,
    creado_en DATETIME DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE usuario_rol (
    id_usuario_rol INT AUTO_INCREMENT PRIMARY KEY,
    id_usuario INT NOT NULL,
    id_rol INT NOT NULL,
    creado_en DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (id_usuario) REFERENCES usuario(id_usuario) ON DELETE CASCADE,
    FOREIGN KEY (id_rol) REFERENCES rol(id_rol),
    UNIQUE (id_usuario, id_rol)
);

CREATE TABLE categoria (
    id_categoria INT AUTO_INCREMENT PRIMARY KEY,
    nombre_categoria VARCHAR(100) NOT NULL UNIQUE,
    descripcion TEXT,
    creado_en DATETIME DEFAULT CURRENT_TIMESTAMP,
    actualizado_en DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

CREATE TABLE producto (
    id_producto INT AUTO_INCREMENT PRIMARY KEY,
    nombre_producto VARCHAR(150) NOT NULL,
    descripcion TEXT,
    id_categoria INT,
    creado_en DATETIME DEFAULT CURRENT_TIMESTAMP,
    actualizado_en DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    disponible BOOLEAN DEFAULT TRUE,
    FOREIGN KEY (id_categoria) REFERENCES categoria(id_categoria)
);

CREATE TABLE producto_variante (
    id_variante INT AUTO_INCREMENT PRIMARY KEY,
    id_producto INT NOT NULL,
    talla VARCHAR(20),
    color VARCHAR(50),
    sku VARCHAR(50) UNIQUE,
    stock INT DEFAULT 0 NOT NULL,
    precio DECIMAL(10, 2) NOT NULL,
    url_imagen VARCHAR(255),
    creado_en DATETIME DEFAULT CURRENT_TIMESTAMP,
    actualizado_en DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (id_producto) REFERENCES producto(id_producto) ON DELETE CASCADE
);

CREATE TABLE pedido (
    id_pedido INT AUTO_INCREMENT PRIMARY KEY,
    id_usuario INT NOT NULL,
    total_pedido DECIMAL(10, 2) NOT NULL,
    estado_pedido ENUM('PENDIENTE', 'PAGADO', 'ENVIADO', 'ENTREGADO', 'CANCELADO', 'DEVUELTO') DEFAULT 'PENDIENTE',
    fecha_pedido DATETIME DEFAULT CURRENT_TIMESTAMP,
    actualizado_en DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (id_usuario) REFERENCES usuario(id_usuario)
);

CREATE TABLE item_pedido (
    id_item_pedido INT AUTO_INCREMENT PRIMARY KEY,
    id_pedido INT NOT NULL,
    id_variante INT NOT NULL,
    cantidad INT NOT NULL,
    precio_unidad DECIMAL(10, 2) NOT NULL,
    subtotal DECIMAL(10, 2) NOT NULL,
    creado_en DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (id_pedido) REFERENCES pedido(id_pedido) ON DELETE CASCADE,
    FOREIGN KEY (id_variante) REFERENCES producto_variante(id_variante)
);

CREATE TABLE carrito_compra (
    id_carrito INT AUTO_INCREMENT PRIMARY KEY,
    id_usuario INT NOT NULL,
    creado_en DATETIME DEFAULT CURRENT_TIMESTAMP,
    actualizado_en DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (id_usuario) REFERENCES usuario(id_usuario) ON DELETE CASCADE,
    UNIQUE (id_usuario)
);

CREATE TABLE item_carrito (
    id_item_carrito INT AUTO_INCREMENT PRIMARY KEY,
    id_carrito INT NOT NULL,
    id_variante INT NOT NULL,
    cantidad INT NOT NULL,
    creado_en DATETIME DEFAULT CURRENT_TIMESTAMP,
    actualizado_en DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (id_carrito) REFERENCES carrito_compra(id_carrito) ON DELETE CASCADE,
    FOREIGN KEY (id_variante) REFERENCES producto_variante(id_variante),
    UNIQUE (id_carrito, id_variante)
);

CREATE TABLE pago (
    id_pago INT AUTO_INCREMENT PRIMARY KEY,
    id_pedido INT NOT NULL UNIQUE,
    metodo_pago VARCHAR(50) NOT NULL,
    monto DECIMAL(10, 2) NOT NULL,
    estado_pago ENUM('PENDIENTE', 'COMPLETADO', 'FALLIDO', 'REEMBOLSADO') DEFAULT 'PENDIENTE',
    id_transaccion VARCHAR(100) UNIQUE,
    creado_en DATETIME DEFAULT CURRENT_TIMESTAMP,
    actualizado_en DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (id_pedido) REFERENCES pedido(id_pedido)
);

CREATE TABLE envio (
    id_envio INT AUTO_INCREMENT PRIMARY KEY,
    id_pedido INT NOT NULL UNIQUE,
    direccion TEXT NOT NULL,
    ciudad VARCHAR(100) NOT NULL,
    pais VARCHAR(100) NOT NULL,
    codigo_postal VARCHAR(20) NOT NULL,
    estado_envio ENUM('PENDIENTE', 'ENVIADO', 'EN_TRANSITO', 'ENTREGADO', 'DEVUELTO') DEFAULT 'PENDIENTE',
    numero_rastreo VARCHAR(100) UNIQUE,
    fecha_envio DATETIME,
    fecha_entrega DATETIME,
    creado_en DATETIME DEFAULT CURRENT_TIMESTAMP,
    actualizado_en DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (id_pedido) REFERENCES pedido(id_pedido)
);

USE tienda_online;

INSERT INTO usuario (email, hash_contrasena, activo) VALUES
('carlos.gomez@example.com', '$2a$10$abcdefghijklmnopqrstuvwxyza123456789012345678901234567890', TRUE),
('ana.martinez@example.com', '$2a$10$abcdefghijklmnopqrstuvwxyza234567890123456789012345678901', TRUE),
('pedro.lopez@example.com', '$2a$10$abcdefghijklmnopqrstuvwxyza345678901234567890123456789012', TRUE),
('maria.rodriguez@example.com', '$2a$10$abcdefghijklmnopqrstuvwxyza456789012345678901234567890123', TRUE),
('juan.perez@example.com', '$2a$10$abcdefghijklmnopqrstuvwxyza567890123456789012345678901234', TRUE),
('laura.gonzalez@example.com', '$2a$10$abcdefghijklmnopqrstuvwxyza678901234567890123456789012345', TRUE),
('sofia.fernandez@example.com', '$2a$10$abcdefghijklmnopqrstuvwxyza789012345678901234567890123456', TRUE),
('javier.torres@example.com', '$2a$10$abcdefghijklmnopqrstuvwxyza890123456789012345678901234567', TRUE),
('marta.ruiz@example.com', '$2a$10$abcdefghijklmnopqrstuvwxyza901234567890123456789012345678', TRUE),
('luis.hernandez@example.com', '$2a$10$abcdefghijklmnopqrstuvwxyza012345678901234567890123456789', TRUE),
('ricardo.sanchez@example.com', '$2a$10$abcdefghijklmnopqrstuvwxyza112345678901234567890123456789', TRUE),
('elena.perez@example.com', '$2a$10$abcdefghijklmnopqrstuvwxyza223456789012345678901234567890', TRUE),
('fernando.mendoza@example.com', '$2a$10$abcdefghijklmnopqrstuvwxyza334567890123456789012345678901', TRUE),
('victoria.martinez@example.com', '$2a$10$abcdefghijklmnopqrstuvwxyza445678901234567890123456789012', TRUE),
('santiago.alvarez@example.com', '$2a$10$abcdefghijklmnopqrstuvwxyza556789012345678901234567890123', TRUE),
('gabriela.diaz@example.com', '$2a$10$abcdefghijklmnopqrstuvwxyza667890123456789012345678901234', TRUE),
('pablo.vega@example.com', '$2a$10$abcdefghijklmnopqrstuvwxyza778901234567890123456789012345', TRUE),
('ines.jimenez@example.com', '$2a$10$abcdefghijklmnopqrstuvwxyza889012345678901234567890123456', TRUE),
('ximena.arara@example.com', '$2a$10$abcdefghijklmnopqrstuvwxyza990123456789012345678901234567', TRUE),
('miguel.romero@example.com', '$2a$10$abcdefghijklmnopqrstuvwxyza001234567890123456789012345678', TRUE);

INSERT INTO tipo_identificacion (nombre_tipo) VALUES
('Cédula de Ciudadanía'),
('Pasaporte'),
('Tarjeta de Identidad'),
('NIT');

INSERT INTO persona (id_usuario, nombre, apellido, telefono, numero_identificacion, id_tipo_identificacion) VALUES
(1, 'Carlos', 'Gomez', '+573101234567', '123456789', 1),
(2, 'Ana', 'Martinez', '+573112345678', '234567890', 1),
(3, 'Pedro', 'Lopez', '+573123456789', '345678901', 2),
(4, 'Maria', 'Rodriguez', '+573134567890', '456789012', 2),
(5, 'Juan', 'Perez', '+573145678901', '567890123', 1),
(6, 'Laura', 'Gonzalez', '+573156789012', '678901234', 3),
(7, 'Sofia', 'Fernandez', '+573167890123', '789012345', 1),
(8, 'Javier', 'Torres', '+573178901234', '890123456', 3),
(9, 'Marta', 'Ruiz', '+573189012345', '901234567', 1),
(10, 'Luis', 'Hernandez', '+573190123456', '012345678', 2),
(11, 'Ricardo', 'Sanchez', '+573201234567', '1234567890', 1),
(12, 'Elena', 'Perez', '+573212345678', '2345678901', 2),
(13, 'Fernando', 'Mendoza', '+573223456789', '3456789012', 3),
(14, 'Victoria', 'Martinez', '+573234567890', '4567890123', 2),
(15, 'Santiago', 'Alvarez', '+573245678901', '5678901234', 1),
(16, 'Gabriela', 'Diaz', '+573256789012', '6789012345', 3),
(17, 'Pablo', 'Vega', '+573267890123', '7890123456', 2),
(18, 'Ines', 'Jimenez', '+573278901234', '8901234567', 1),
(19, 'Ximena', 'Arara', '+573234341234', '3298473982', 1),
(20, 'Miguel', 'Romero', '+573289012345', '9012345678', 3);

INSERT INTO rol (nombre_rol) VALUES
('admin'),
('cliente'),
('vendedor');

INSERT INTO usuario_rol (id_usuario, id_rol) VALUES
(1, 1), (2, 2), (3, 2), (4, 2), (5, 2),
(6, 2), (7, 2), (8, 2), (9, 2), (10, 2),
(11, 3), (12, 3), (13, 2), (14, 2), (15, 2),
(16, 3), (17, 2), (18, 2), (19, 2), (20, 2);

INSERT INTO categoria (nombre_categoria, descripcion) VALUES
('Camisetas', 'Prendas superiores ligeras y cómodas.'),
('Pantalones', 'Prendas inferiores para cualquier ocasión.'),
('Chaquetas', 'Prendas de abrigo para diferentes climas.'),
('Accesorios', 'Complementos para realzar tu estilo.'),
('Calzado', 'Todo tipo de zapatos para hombres y mujeres.');

INSERT INTO producto (nombre_producto, descripcion, id_categoria, disponible) VALUES
('Camiseta Básica Algodón', 'Camiseta de algodón 100% orgánico, ideal para el día a día. Disponible en varios colores y tallas.', 1, TRUE),
('Jeans Slim Fit', 'Jeans de mezclilla con corte ajustado, cómodos y modernos. Perfectos para un look casual.', 2, TRUE),
('Chaqueta Bomber Impermeable', 'Chaqueta ligera e impermeable, ideal para la lluvia y el viento. Diseño moderno y versátil.', 3, TRUE),
('Gafas de Sol Polarizadas', 'Gafas de sol con lentes polarizadas para máxima protección UV. Diseño unisex y duradero.', 4, TRUE),
('Zapatillas Running Pro', 'Zapatillas deportivas de alto rendimiento, diseñadas para corredores. Excelente amortiguación y soporte.', 5, TRUE),
('Camiseta Gráfica Vintage', 'Camiseta con estampado gráfico de estilo vintage, 100% algodón. Un toque retro para tu armario.', 1, TRUE),
('Pantalón Chino Elástico', 'Pantalón chino con tejido elástico para mayor comodidad. Ideal para looks casuales y semi-formales.', 2, TRUE),
('Sudadera con Capucha Premium', 'Sudadera con capucha de algodón premium, suave y cálida. Perfecta para el invierno.', 3, TRUE),
('Mochila Urbana Antirrobo', 'Mochila con diseño antirrobo y múltiples compartimentos. Ideal para la ciudad y viajes cortos.', 4, TRUE),
('Botines de Cuero Genuino', 'Botines elegantes de cuero genuino, con suela antideslizante. Perfectos para un estilo sofisticado.', 5, TRUE);

INSERT INTO producto_variante (id_producto, talla, color, sku, stock, precio, url_imagen) VALUES
(1, 'S', 'Blanco', 'TSHIRT-BAS-WHT-S', 50, 14.99, '/img/camiseta-basica-blanca-s.jpg'),
(1, 'M', 'Blanco', 'TSHIRT-BAS-WHT-M', 60, 14.99, '/img/camiseta-basica-blanca-m.jpg'),
(1, 'L', 'Blanco', 'TSHIRT-BAS-WHT-L', 40, 14.99, '/img/camiseta-basica-blanca-l.jpg'),
(2, '32', 'Azul Oscuro', 'JEANS-SLIM-DBL-32', 70, 29.99, '/img/jeans-slim-azul-32.jpg'),
(2, '34', 'Azul Oscuro', 'JEANS-SLIM-DBL-34', 80, 29.99, '/img/jeans-slim-azul-34.jpg'),
(2, '36', 'Azul Oscuro', 'JEANS-SLIM-DBL-36', 60, 29.99, '/img/jeans-slim-azul-36.jpg'),
(3, 'M', 'Negro', 'BOMBER-BLK-M', 20, 99.99, '/img/chaqueta-bomber-negra-m.jpg'),
(3, 'L', 'Negro', 'BOMBER-BLK-L', 15, 99.99, '/img/chaqueta-bomber-negra-l.jpg'),
(4, 'Única', 'Negro', 'SUNGLASS-POL-BLK', 150, 19.99, '/img/gafas-sol-polarizadas-negro.jpg'),
(5, '42', 'Blanco/Gris', 'RUNNING-SHOE-WHT-42', 30, 59.99, '/img/zapatillas-running-blanco-42.jpg'),
(5, '43', 'Blanco/Gris', 'RUNNING-SHOE-WHT-43', 40, 59.99, '/img/zapatillas-running-blanco-43.jpg'),
(6, 'S', 'Rojo', 'TSHIRT-GRAPHIC-RED-S', 70, 16.99, '/img/camiseta-grafica-roja-s.jpg'),
(6, 'M', 'Rojo', 'TSHIRT-GRAPHIC-RED-M', 50, 16.99, '/img/camiseta-grafica-roja-m.jpg'),
(7, 'L', 'Beige', 'CHINO-PANTS-BGE-L', 60, 25.99, '/img/pantalon-chino-beige-l.jpg'),
(7, 'M', 'Beige', 'CHINO-PANTS-BGE-M', 80, 25.99, '/img/pantalon-chino-beige-m.jpg'),
(8, 'M', 'Gris Melange', 'HOODIE-GRY-M', 50, 89.99, '/img/sudadera-gris-m.jpg'),
(8, 'L', 'Gris Melange', 'HOODIE-GRY-L', 40, 89.99, '/img/sudadera-gris-l.jpg'),
(9, 'Única', 'Negro', 'BACKPACK-URB-BLK', 100, 49.99, '/img/mochila-urbana-negro.jpg'),
(10, '42', 'Marrón Oscuro', 'BOOTS-LEATHER-BRN-42', 30, 129.99, '/img/botines-cuero-marron-42.jpg'),
(10, '43', 'Marrón Oscuro', 'BOOTS-LEATHER-BRN-43', 40, 129.99, '/img/botines-cuero-marron-43.jpg');

INSERT INTO carrito_compra (id_usuario) VALUES
(1), (2), (3), (4), (5), (6), (7), (8), (9), (10),
(11), (12), (13), (14), (15), (16), (17), (18), (19), (20);

INSERT INTO item_carrito (id_carrito, id_variante, cantidad) VALUES
(1, 1, 3), (2, 4, 2), (3, 7, 1), (4, 9, 1), (5, 10, 2),
(6, 12, 1), (7, 14, 2), (8, 16, 1), (9, 18, 2), (10, 19, 1),
(11, 11, 1), (12, 13, 1), (13, 15, 1), (14, 17, 1), (15, 20, 1),
(16, 10, 2), (17, 9, 1), (18, 11, 2), (19, 9, 1), (20, 20, 1);

INSERT INTO pedido (id_usuario, total_pedido, estado_pedido) VALUES
(1, 44.97, 'PAGADO'),
(2, 59.98, 'PENDIENTE'),
(3, 99.99, 'PAGADO'),
(4, 19.99, 'ENVIADO'),
(5, 119.98, 'CANCELADO'),
(6, 16.99, 'PENDIENTE'),
(7, 51.98, 'PAGADO'),
(8, 89.99, 'PENDIENTE'),
(9, 99.98, 'ENVIADO'),
(10, 129.99, 'PAGADO'),
(11, 59.99, 'PENDIENTE'),
(12, 16.99, 'CANCELADO'),
(13, 25.99, 'PAGADO'),
(14, 89.99, 'PENDIENTE'),
(15, 129.99, 'ENVIADO'),
(16, 119.98, 'PAGADO'),
(17, 19.99, 'CANCELADO'),
(18, 119.98, 'PENDIENTE'),
(19, 49.99, 'PAGADO'),
(20, 129.99, 'PENDIENTE');

INSERT INTO item_pedido (id_pedido, id_variante, cantidad, precio_unidad, subtotal) VALUES
(1, 1, 3, 14.99, 44.97),
(2, 4, 2, 29.99, 59.98),
(3, 7, 1, 99.99, 99.99),
(4, 9, 1, 19.99, 19.99),
(5, 10, 2, 59.99, 119.98),
(6, 12, 1, 16.99, 16.99),
(7, 14, 2, 25.99, 51.98),
(8, 16, 1, 89.99, 89.99),
(9, 18, 2, 49.99, 99.98),
(10, 19, 1, 129.99, 129.99),
(11, 11, 1, 59.99, 59.99),
(12, 13, 1, 16.99, 16.99),
(13, 15, 1, 25.99, 25.99),
(14, 17, 1, 89.99, 89.99),
(15, 20, 1, 129.99, 129.99),
(16, 10, 2, 59.99, 119.98),
(17, 9, 1, 19.99, 19.99),
(18, 11, 2, 59.99, 119.98),
(19, 9, 1, 49.99, 49.99),
(20, 20, 1, 129.99, 129.99);

INSERT INTO pago (id_pedido, metodo_pago, monto, estado_pago, id_transaccion) VALUES
(1, 'Tarjeta de Crédito', 44.97, 'COMPLETADO', 'TRX123456789'),
(2, 'Transferencia Bancaria', 59.98, 'PENDIENTE', NULL),
(3, 'PayPal', 99.99, 'COMPLETADO', 'PYPL987654321'),
(4, 'Tarjeta de Crédito', 19.99, 'COMPLETADO', 'TRX123456790'),
(5, 'Efectivo', 119.98, 'FALLIDO', NULL),
(6, 'Tarjeta de Crédito', 16.99, 'PENDIENTE', NULL),
(7, 'PayPal', 51.98, 'COMPLETADO', 'PYPL987654322'),
(8, 'Transferencia Bancaria', 89.99, 'PENDIENTE', NULL),
(9, 'Efectivo', 99.98, 'COMPLETADO', 'CASH0001'),
(10, 'PayPal', 129.99, 'COMPLETADO', 'PYPL987654323'),
(11, 'Tarjeta de Crédito', 59.99, 'PENDIENTE', NULL),
(12, 'Efectivo', 16.99, 'FALLIDO', NULL),
(13, 'PayPal', 25.99, 'COMPLETADO', 'PYPL987654324'),
(14, 'Transferencia Bancaria', 89.99, 'PENDIENTE', NULL),
(15, 'Tarjeta de Crédito', 129.99, 'COMPLETADO', 'TRX123456791'),
(16, 'Efectivo', 119.98, 'COMPLETADO', 'CASH0002'),
(17, 'PayPal', 19.99, 'FALLIDO', NULL),
(18, 'Tarjeta de Crédito', 119.98, 'PENDIENTE', NULL),
(19, 'Transferencia Bancaria', 49.99, 'COMPLETADO', 'TRX123456792'),
(20, 'Efectivo', 129.99, 'PENDIENTE', NULL);

INSERT INTO envio (id_pedido, direccion, ciudad, pais, codigo_postal, estado_envio, numero_rastreo, fecha_envio, fecha_entrega) VALUES
(1, 'Calle Falsa 123', 'Madrid', 'España', '28080', 'ENTREGADO', 'ES123456789', '2025-05-20 10:00:00', '2025-05-25 15:30:00'),
(2, 'Av. Libertador 456', 'Buenos Aires', 'Argentina', 'C1001', 'PENDIENTE', NULL, NULL, NULL),
(3, 'Rua das Flores 789', 'Lisboa', 'Portugal', '1200-345', 'ENTREGADO', 'PT987654321', '2025-05-21 11:00:00', '2025-05-26 10:00:00'),
(4, 'Main Street 101', 'Nueva York', 'EE.UU.', '10001', 'ENVIADO', 'US456789012', '2025-05-22 14:00:00', NULL),
(5, 'Calle del Sol 567', 'Ciudad de México', 'México', '01000', 'DEVUELTO', NULL, '2025-05-23 09:00:00', '2025-05-25 18:00:00'),
(6, 'Avenida Paulista 800', 'São Paulo', 'Brasil', '01310-100', 'PENDIENTE', NULL, NULL, NULL),
(7, 'Carrer de Pau Claris 12', 'Barcelona', 'España', '08010', 'ENTREGADO', 'ES123456790', '2025-05-20 12:00:00', '2025-05-24 16:00:00'),
(8, 'Via Nazionale 45', 'Roma', 'Italia', '00184', 'PENDIENTE', NULL, NULL, NULL),
(9, 'Champs-Élysées 50', 'París', 'Francia', '75008', 'ENVIADO', 'FR567890123', '2025-05-22 10:00:00', NULL),
(10, 'Calle Serrano 100', 'Madrid', 'España', '28006', 'ENTREGADO', 'ES123456791', '2025-05-21 15:00:00', '2025-05-25 11:00:00'),
(11, 'Avenida del Valle 22', 'Santiago', 'Chile', '8320000', 'PENDIENTE', NULL, NULL, NULL),
(12, 'Broadway 56', 'Los Ángeles', 'EE.UU.', '90012', 'DEVUELTO', NULL, '2025-05-23 11:00:00', '2025-05-26 09:00:00'),
(13, 'Calle Mayor 34', 'Valencia', 'España', '46001', 'ENTREGADO', 'ES123456792', '2025-05-20 14:00:00', '2025-05-24 10:00:00'),
(14, 'Boulevard de la Reine 11', 'Bruselas', 'Bélgica', '1000', 'PENDIENTE', NULL, NULL, NULL),
(15, 'Calle Mayor 90', 'Sevilla', 'España', '41001', 'ENVIADO', 'ES123456793', '2025-05-22 16:00:00', NULL),
(16, 'Avenida Santa Fe 300', 'Ciudad de México', 'México', '06000', 'ENTREGADO', 'MX123456789', '2025-05-21 09:00:00', '2025-05-25 14:00:00'),
(17, 'Rua Augusta 120', 'São Paulo', 'Brasil', '01305-000', 'DEVUELTO', NULL, '2025-05-23 13:00:00', '2025-05-26 12:00:00'),
(18, 'Calle de Alcalá 100', 'Madrid', 'España', '28009', 'PENDIENTE', NULL, NULL, NULL),
(19, 'Viale Mazzini 7', 'Roma', 'Italia', '00195', 'ENVIADO', 'IT123456789', '2025-05-22 17:00:00', NULL),
(20, 'Paseo de la Castellana 34', 'Madrid', 'España', '28046', 'PENDIENTE', NULL, NULL, NULL);