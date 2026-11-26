-- ============================================================================
-- Base de Datos: DecorArte
-- Descripción: Esquema para catálogos dinámicos, productos, clientes, pedidos
--              y pagos con Mercado Pago (Oracle Cloud / MySQL / PostgreSQL).
-- ============================================================================

CREATE TABLE catalogos (
    id              INT PRIMARY KEY,
    slug            VARCHAR(60) NOT NULL UNIQUE,
    nombre          VARCHAR(100) NOT NULL,
    habilitado      BOOLEAN NOT NULL DEFAULT TRUE,
    es_temporada    BOOLEAN NOT NULL DEFAULT FALSE,
    creado_en       TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE productos (
    id              INT PRIMARY KEY,
    codigo          VARCHAR(40) NOT NULL UNIQUE,
    nombre          VARCHAR(150) NOT NULL,
    categoria       VARCHAR(60) NOT NULL,
    subcategoria    VARCHAR(80),
    precio          DECIMAL(10, 2) NOT NULL,
    precio_anterior DECIMAL(10, 2),
    en_oferta       BOOLEAN NOT NULL DEFAULT FALSE,
    stock           INT NOT NULL DEFAULT 0,
    es_temporada    BOOLEAN NOT NULL DEFAULT FALSE,
    descripcion     TEXT,
    imagen_url      TEXT,
    activo          BOOLEAN NOT NULL DEFAULT TRUE,
    creado_en       TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE clientes (
    id              INT PRIMARY KEY,
    nombre          VARCHAR(150) NOT NULL,
    telefono        VARCHAR(25) NOT NULL,
    direccion       VARCHAR(300),
    colonia         VARCHAR(150),
    referencias     VARCHAR(300),
    creado_en       TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE pedidos (
    id              INT PRIMARY KEY,
    cliente_id      INT NOT NULL,
    tipo_entrega    VARCHAR(30) NOT NULL, -- 'tienda' | 'domicilio'
    metodo_pago     VARCHAR(40) NOT NULL, -- 'mercadopago_online' | 'mercadopago_terminal'
    estado          VARCHAR(30) NOT NULL DEFAULT 'pendiente',
    total           DECIMAL(10, 2) NOT NULL,
    notas           TEXT,
    creado_en       TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (cliente_id) REFERENCES clientes(id)
);

CREATE TABLE detalle_pedidos (
    id              INT PRIMARY KEY,
    pedido_id       INT NOT NULL,
    producto_id     INT NOT NULL,
    cantidad        INT NOT NULL,
    precio_unitario DECIMAL(10, 2) NOT NULL,
    FOREIGN KEY (pedido_id) REFERENCES pedidos(id),
    FOREIGN KEY (producto_id) REFERENCES productos(id)
);

CREATE TABLE pagos_mercadopago (
    id                  INT PRIMARY KEY,
    pedido_id           INT NOT NULL,
    mp_payment_id       VARCHAR(100),
    mp_preference_id    VARCHAR(100),
    estado_pago         VARCHAR(40) NOT NULL DEFAULT 'pendiente',
    monto               DECIMAL(10, 2) NOT NULL,
    actualizado_en      TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (pedido_id) REFERENCES pedidos(id)
);

-- ============================================================================
-- Datos iniciales de Catálogos y Productos (49 artículos)
-- ============================================================================
INSERT INTO catalogos (id, slug, nombre, habilitado, es_temporada) VALUES (1, 'cuadros', 'Cuadros', TRUE, FALSE);
INSERT INTO catalogos (id, slug, nombre, habilitado, es_temporada) VALUES (2, 'espejos', 'Espejos', TRUE, FALSE);
INSERT INTO catalogos (id, slug, nombre, habilitado, es_temporada) VALUES (3, 'mesas', 'Mesas de Cristal', TRUE, FALSE);
INSERT INTO catalogos (id, slug, nombre, habilitado, es_temporada) VALUES (4, 'ceramica', 'Cerámica', TRUE, FALSE);
INSERT INTO catalogos (id, slug, nombre, habilitado, es_temporada) VALUES (5, 'navidad', 'Navidad', TRUE, TRUE);

INSERT INTO productos (id, codigo, nombre, categoria, subcategoria, precio, precio_anterior, en_oferta, stock, es_temporada, descripcion, imagen_url, activo) VALUES (1, 'DA-CUA-001', 'Cuadro Abstracto Dorado & Mármol', 'cuadros', '', 1850.00, 2200.00, TRUE, 5, FALSE, 'Lienzo enmarcado en acabado dorado cepillado, ideal para sala o recibidor.', 'https://images.unsplash.com/photo-1579783902614-a3fb3927b6a5?auto=format&fit=crop&w=600&q=80', TRUE);
INSERT INTO productos (id, codigo, nombre, categoria, subcategoria, precio, precio_anterior, en_oferta, stock, es_temporada, descripcion, imagen_url, activo) VALUES (2, 'DA-CUA-002', 'Díptico Minimalista Arena & Oro', 'cuadros', '', 2450.00, NULL, FALSE, 4, FALSE, 'Set de dos cuadros en tonos beige y detalles metálicos dorados.', 'https://images.unsplash.com/photo-1513519245088-0e12902e5a38?auto=format&fit=crop&w=600&q=80', TRUE);
INSERT INTO productos (id, codigo, nombre, categoria, subcategoria, precio, precio_anterior, en_oferta, stock, es_temporada, descripcion, imagen_url, activo) VALUES (3, 'DA-ESP-001', 'Espejo Circular Marco Dorado', 'espejos', '', 2400.00, NULL, FALSE, 3, FALSE, 'Espejo de 80 cm con marco metálico en tono champagne dorado.', 'https://images.unsplash.com/photo-1618220179428-22790b461013?auto=format&fit=crop&w=600&q=80', TRUE);
INSERT INTO productos (id, codigo, nombre, categoria, subcategoria, precio, precio_anterior, en_oferta, stock, es_temporada, descripcion, imagen_url, activo) VALUES (4, 'DA-ESP-002', 'Espejo Arco de Cuerpo Completo', 'espejos', '', 3690.00, 4100.00, TRUE, 2, FALSE, 'Espejo estilo arco con borde fino dorado, perfecto para recámara o vestidor.', 'https://images.unsplash.com/photo-1616486338812-3dadae4b4ace?auto=format&fit=crop&w=600&q=80', TRUE);
INSERT INTO productos (id, codigo, nombre, categoria, subcategoria, precio, precio_anterior, en_oferta, stock, es_temporada, descripcion, imagen_url, activo) VALUES (5, 'DA-MES-001', 'Mesa Auxiliar de Cristal y Latón', 'mesas', '', 3200.00, NULL, FALSE, 4, FALSE, 'Mesa pequeña con cubierta de cristal templado y base dorada minimalista.', 'https://images.unsplash.com/photo-1533090481720-856c6e3c1fdc?auto=format&fit=crop&w=600&q=80', TRUE);
INSERT INTO productos (id, codigo, nombre, categoria, subcategoria, precio, precio_anterior, en_oferta, stock, es_temporada, descripcion, imagen_url, activo) VALUES (6, 'DA-MES-002', 'Mesa de Centro Redonda Cristal Templado', 'mesas', '', 4350.00, 4900.00, TRUE, 3, FALSE, 'Mesa elegante con doble nivel de cristal y estructura en tono dorado mate.', 'https://images.unsplash.com/photo-1555041469-a586c61ea9bc?auto=format&fit=crop&w=600&q=80', TRUE);
INSERT INTO productos (id, codigo, nombre, categoria, subcategoria, precio, precio_anterior, en_oferta, stock, es_temporada, descripcion, imagen_url, activo) VALUES (7, 'DA-CER-001', 'Figura de Cerámica Orgánica Beige', 'ceramica', '', 680.00, NULL, FALSE, 10, FALSE, 'Escultura decorativa de cerámica mate en tono arena, hecha a mano.', 'https://images.unsplash.com/photo-1610701596007-11502861dcfa?auto=format&fit=crop&w=600&q=80', TRUE);
INSERT INTO productos (id, codigo, nombre, categoria, subcategoria, precio, precio_anterior, en_oferta, stock, es_temporada, descripcion, imagen_url, activo) VALUES (8, 'DA-CER-002', 'Set de 3 Jarrones Cerámica Minimal', 'ceramica', '', 820.00, 950.00, TRUE, 6, FALSE, 'Trío de piezas en cerámica beige y blanco hueso para centro de mesa.', 'https://images.unsplash.com/photo-1578500494198-246f612d3b3d?auto=format&fit=crop&w=600&q=80', TRUE);
INSERT INTO productos (id, codigo, nombre, categoria, subcategoria, precio, precio_anterior, en_oferta, stock, es_temporada, descripcion, imagen_url, activo) VALUES (9, 'DA-CER-003', 'Busto Decorativo Cerámica Blanco Mate', 'ceramica', '', 740.00, NULL, FALSE, 7, FALSE, 'Figura escultórica pequeña de cerámica fina en acabado blanco porcelana.', 'https://images.unsplash.com/photo-1565193566173-7a0ee3dbe261?auto=format&fit=crop&w=600&q=80', TRUE);
INSERT INTO productos (id, codigo, nombre, categoria, subcategoria, precio, precio_anterior, en_oferta, stock, es_temporada, descripcion, imagen_url, activo) VALUES (10, 'DA-ARB-001', 'Árbol Artificial Nevado Elegante 2.10 m', 'navidad', 'Árboles artificiales', 3890.00, 4500.00, TRUE, 4, TRUE, 'Árbol navideño artificial frondoso con acabado nevado y base metálica.', 'https://images.unsplash.com/photo-1544967082-d9d25d867d66?auto=format&fit=crop&w=600&q=80', TRUE);
INSERT INTO productos (id, codigo, nombre, categoria, subcategoria, precio, precio_anterior, en_oferta, stock, es_temporada, descripcion, imagen_url, activo) VALUES (11, 'DA-ARB-002', 'Árbol Pino Canadiense Clásico 1.80 m', 'navidad', 'Árboles artificiales', 2950.00, NULL, FALSE, 6, TRUE, 'Ramas densas de aspecto natural, fácil armado para sala o recibidor.', 'https://images.unsplash.com/photo-1512389142860-9c449e58a543?auto=format&fit=crop&w=600&q=80', TRUE);
INSERT INTO productos (id, codigo, nombre, categoria, subcategoria, precio, precio_anterior, en_oferta, stock, es_temporada, descripcion, imagen_url, activo) VALUES (12, 'DA-ARB-003', 'Árbol Slim Dorado & Luz Cálida 1.90 m', 'navidad', 'Árboles artificiales', 3450.00, NULL, FALSE, 3, TRUE, 'Diseño estilizado ideal para espacios compactos con luces LED integradas.', 'https://images.unsplash.com/photo-1543589077-47d81606c1bf?auto=format&fit=crop&w=600&q=80', TRUE);
INSERT INTO productos (id, codigo, nombre, categoria, subcategoria, precio, precio_anterior, en_oferta, stock, es_temporada, descripcion, imagen_url, activo) VALUES (13, 'DA-ARB-004', 'Mini Árbol de Mesa Base Yute 60 cm', 'navidad', 'Árboles artificiales', 590.00, NULL, FALSE, 14, TRUE, 'Pino artificial pequeño en maceta de yute beige para escritorio o consola.', 'https://images.unsplash.com/photo-1513297887119-d46091b24bfa?auto=format&fit=crop&w=600&q=80', TRUE);
INSERT INTO productos (id, codigo, nombre, categoria, subcategoria, precio, precio_anterior, en_oferta, stock, es_temporada, descripcion, imagen_url, activo) VALUES (14, 'DA-ARB-005', 'Árbol Champagne Escarchado 2.40 m', 'navidad', 'Árboles artificiales', 5200.00, 5800.00, TRUE, 2, TRUE, 'Árbol de gran formato con destellos dorados y ramas articuladas.', 'https://images.unsplash.com/photo-1576919228236-a097c32a5cd4?auto=format&fit=crop&w=600&q=80', TRUE);
INSERT INTO productos (id, codigo, nombre, categoria, subcategoria, precio, precio_anterior, en_oferta, stock, es_temporada, descripcion, imagen_url, activo) VALUES (15, 'DA-FOL-001', 'Guirnalda de Follaje Pino & Dorado (2 m)', 'navidad', 'Follaje', 650.00, NULL, FALSE, 12, TRUE, 'Follaje artificial realista con piñas y toques dorados para chimenea.', 'https://images.unsplash.com/photo-1512909006721-3d6018887383?auto=format&fit=crop&w=600&q=80', TRUE);
INSERT INTO productos (id, codigo, nombre, categoria, subcategoria, precio, precio_anterior, en_oferta, stock, es_temporada, descripcion, imagen_url, activo) VALUES (16, 'DA-FOL-002', 'Ramas de Eucalipto Dorado (Set x4)', 'navidad', 'Follaje', 380.00, NULL, FALSE, 20, TRUE, 'Varas decorativas en acabado oro mate para jarrones o árbol navideño.', 'https://images.unsplash.com/photo-1511268011861-691ed210aae8?auto=format&fit=crop&w=600&q=80', TRUE);
INSERT INTO productos (id, codigo, nombre, categoria, subcategoria, precio, precio_anterior, en_oferta, stock, es_temporada, descripcion, imagen_url, activo) VALUES (17, 'DA-FOL-003', 'Pick de Bayas Blancas & Pino Nevado', 'navidad', 'Follaje', 240.00, NULL, FALSE, 25, TRUE, 'Ramillete invernal ideal para complementar coronas y centros de mesa.', 'https://images.unsplash.com/photo-1544967082-d9d25d867d66?auto=format&fit=crop&w=600&q=80', TRUE);
INSERT INTO productos (id, codigo, nombre, categoria, subcategoria, precio, precio_anterior, en_oferta, stock, es_temporada, descripcion, imagen_url, activo) VALUES (18, 'DA-FOL-004', 'Guirnalda Ciprés con Luces LED 2.7 m', 'navidad', 'Follaje', 890.00, 1050.00, TRUE, 8, TRUE, 'Guirnalda tupida de ciprés con micro luces cálidas para barandal.', 'https://images.unsplash.com/photo-1512389142860-9c449e58a543?auto=format&fit=crop&w=600&q=80', TRUE);
INSERT INTO productos (id, codigo, nombre, categoria, subcategoria, precio, precio_anterior, en_oferta, stock, es_temporada, descripcion, imagen_url, activo) VALUES (19, 'DA-FOL-005', 'Hojas de Ginkgo Metálicas Champagne', 'navidad', 'Follaje', 460.00, NULL, FALSE, 15, TRUE, 'Set de 3 varas de follaje elegante para arreglos navideños.', 'https://images.unsplash.com/photo-1543589077-47d81606c1bf?auto=format&fit=crop&w=600&q=80', TRUE);
INSERT INTO productos (id, codigo, nombre, categoria, subcategoria, precio, precio_anterior, en_oferta, stock, es_temporada, descripcion, imagen_url, activo) VALUES (20, 'DA-NOC-001', 'Nochebuena Terciopelo Champagne (Set x3)', 'navidad', 'Nochebuenas', 420.00, NULL, FALSE, 18, TRUE, 'Flores de nochebuena decorativas en terciopelo beige y centro dorado.', 'https://images.unsplash.com/photo-1576919228236-a097c32a5cd4?auto=format&fit=crop&w=600&q=80', TRUE);
INSERT INTO productos (id, codigo, nombre, categoria, subcategoria, precio, precio_anterior, en_oferta, stock, es_temporada, descripcion, imagen_url, activo) VALUES (21, 'DA-NOC-002', 'Nochebuena Blanca con Brillo Oro (Set x4)', 'navidad', 'Nochebuenas', 480.00, NULL, FALSE, 16, TRUE, 'Pétalos blancos con bordes escarchados en dorado y clip integrado.', 'https://images.unsplash.com/photo-1512909006721-3d6018887383?auto=format&fit=crop&w=600&q=80', TRUE);
INSERT INTO productos (id, codigo, nombre, categoria, subcategoria, precio, precio_anterior, en_oferta, stock, es_temporada, descripcion, imagen_url, activo) VALUES (22, 'DA-NOC-003', 'Nochebuena Clásica Roja Terciopelo (Set x3)', 'navidad', 'Nochebuenas', 390.00, 460.00, TRUE, 20, TRUE, 'Nochebuenas tradicionales de gran tamaño para árbol o guirnalda.', 'https://images.unsplash.com/photo-1513297887119-d46091b24bfa?auto=format&fit=crop&w=600&q=80', TRUE);
INSERT INTO productos (id, codigo, nombre, categoria, subcategoria, precio, precio_anterior, en_oferta, stock, es_temporada, descripcion, imagen_url, activo) VALUES (23, 'DA-NOC-004', 'Maceta Nochebuena Artificial Crema', 'navidad', 'Nochebuenas', 620.00, NULL, FALSE, 9, TRUE, 'Arreglo completo en maceta de cerámica beige listo para mesa de centro.', 'https://images.unsplash.com/photo-1511268011861-691ed210aae8?auto=format&fit=crop&w=600&q=80', TRUE);
INSERT INTO productos (id, codigo, nombre, categoria, subcategoria, precio, precio_anterior, en_oferta, stock, es_temporada, descripcion, imagen_url, activo) VALUES (24, 'DA-NOC-005', 'Nochebuena Malla Dorada Calada (Set x6)', 'navidad', 'Nochebuenas', 540.00, NULL, FALSE, 14, TRUE, 'Flores ligeras de malla metálica dorada para dar volumen al árbol.', 'https://images.unsplash.com/photo-1545048702-79362596cdc9?auto=format&fit=crop&w=600&q=80', TRUE);
INSERT INTO productos (id, codigo, nombre, categoria, subcategoria, precio, precio_anterior, en_oferta, stock, es_temporada, descripcion, imagen_url, activo) VALUES (25, 'DA-ESF-001', 'Esferas de Cristal y Hoja de Oro (Set x6)', 'navidad', 'Esferas', 690.00, 790.00, TRUE, 15, TRUE, 'Juego de 6 esferas navideñas elegantes en cristal transparente y dorado.', 'https://images.unsplash.com/photo-1543589077-47d81606c1bf?auto=format&fit=crop&w=600&q=80', TRUE);
INSERT INTO productos (id, codigo, nombre, categoria, subcategoria, precio, precio_anterior, en_oferta, stock, es_temporada, descripcion, imagen_url, activo) VALUES (26, 'DA-ESF-002', 'Esferas Terciopelo Beige & Perla (Set x12)', 'navidad', 'Esferas', 750.00, NULL, FALSE, 11, TRUE, 'Esferas forradas en terciopelo suave tono arena con casquillo dorado.', 'https://images.unsplash.com/photo-1512389142860-9c449e58a543?auto=format&fit=crop&w=600&q=80', TRUE);
INSERT INTO productos (id, codigo, nombre, categoria, subcategoria, precio, precio_anterior, en_oferta, stock, es_temporada, descripcion, imagen_url, activo) VALUES (27, 'DA-ESF-003', 'Esferas Champagne Satinadas 8 cm (Set x8)', 'navidad', 'Esferas', 560.00, NULL, FALSE, 18, TRUE, 'Acabado mate y brillante combinado para un árbol sofisticado.', 'https://images.unsplash.com/photo-1576919228236-a097c32a5cd4?auto=format&fit=crop&w=600&q=80', TRUE);
INSERT INTO productos (id, codigo, nombre, categoria, subcategoria, precio, precio_anterior, en_oferta, stock, es_temporada, descripcion, imagen_url, activo) VALUES (28, 'DA-ESF-004', 'Esferas Caladas Filigrana Oro (Set x4)', 'navidad', 'Esferas', 620.00, NULL, FALSE, 10, TRUE, 'Esferas metálicas con diseño calado estilo vintage dorado.', 'https://images.unsplash.com/photo-1512909006721-3d6018887383?auto=format&fit=crop&w=600&q=80', TRUE);
INSERT INTO productos (id, codigo, nombre, categoria, subcategoria, precio, precio_anterior, en_oferta, stock, es_temporada, descripcion, imagen_url, activo) VALUES (29, 'DA-ESF-005', 'Tubo de 24 Esferas Irrompibles Blanco/Oro', 'navidad', 'Esferas', 840.00, 980.00, TRUE, 9, TRUE, 'Colección completa en tres tamaños para vestir todo tu árbol.', 'https://images.unsplash.com/photo-1544967082-d9d25d867d66?auto=format&fit=crop&w=600&q=80', TRUE);
INSERT INTO productos (id, codigo, nombre, categoria, subcategoria, precio, precio_anterior, en_oferta, stock, es_temporada, descripcion, imagen_url, activo) VALUES (30, 'DA-VIL-001', 'Villa Navideña Iluminada de Porcelana', 'navidad', 'Villas navideñas', 1650.00, NULL, FALSE, 5, TRUE, 'Casita navideña en cerámica blanca con luz LED cálida para mesa o repisa.', 'https://images.unsplash.com/photo-1513297887119-d46091b24bfa?auto=format&fit=crop&w=600&q=80', TRUE);
INSERT INTO productos (id, codigo, nombre, categoria, subcategoria, precio, precio_anterior, en_oferta, stock, es_temporada, descripcion, imagen_url, activo) VALUES (31, 'DA-VIL-002', 'Set 3 Casitas Nórdicas Beige & Madera', 'navidad', 'Villas navideñas', 1290.00, NULL, FALSE, 7, TRUE, 'Trío de casas minimalistas con iluminación cálida a baterías.', 'https://images.unsplash.com/photo-1511268011861-691ed210aae8?auto=format&fit=crop&w=600&q=80', TRUE);
INSERT INTO productos (id, codigo, nombre, categoria, subcategoria, precio, precio_anterior, en_oferta, stock, es_temporada, descripcion, imagen_url, activo) VALUES (32, 'DA-VIL-003', 'Iglesia Nevada con Carrusel Musical', 'navidad', 'Villas navideñas', 2150.00, 2490.00, TRUE, 3, TRUE, 'Pieza central animada con música navideña y detalles dorados.', 'https://images.unsplash.com/photo-1545048702-79362596cdc9?auto=format&fit=crop&w=600&q=80', TRUE);
INSERT INTO productos (id, codigo, nombre, categoria, subcategoria, precio, precio_anterior, en_oferta, stock, es_temporada, descripcion, imagen_url, activo) VALUES (33, 'DA-VIL-004', 'Panadería Invernal de Cerámica LED', 'navidad', 'Villas navideñas', 1420.00, NULL, FALSE, 6, TRUE, 'Edificio navideño detallado con nieve artificial y luz interior.', 'https://images.unsplash.com/photo-1543589077-47d81606c1bf?auto=format&fit=crop&w=600&q=80', TRUE);
INSERT INTO productos (id, codigo, nombre, categoria, subcategoria, precio, precio_anterior, en_oferta, stock, es_temporada, descripcion, imagen_url, activo) VALUES (34, 'DA-VIL-005', 'Estación de Tren Navideña Iluminada', 'navidad', 'Villas navideñas', 1890.00, NULL, FALSE, 4, TRUE, 'Escena clásica navideña para armar tu villa sobre consola o repisa.', 'https://images.unsplash.com/photo-1512389142860-9c449e58a543?auto=format&fit=crop&w=600&q=80', TRUE);
INSERT INTO productos (id, codigo, nombre, categoria, subcategoria, precio, precio_anterior, en_oferta, stock, es_temporada, descripcion, imagen_url, activo) VALUES (35, 'DA-COR-001', 'Corona de Encino y Hojas Doradas', 'navidad', 'Coronas de encino', 1150.00, NULL, FALSE, 8, TRUE, 'Corona artesanal de encino con detalles dorados y bayas invernales.', 'https://images.unsplash.com/photo-1512389142860-9c449e58a543?auto=format&fit=crop&w=600&q=80', TRUE);
INSERT INTO productos (id, codigo, nombre, categoria, subcategoria, precio, precio_anterior, en_oferta, stock, es_temporada, descripcion, imagen_url, activo) VALUES (36, 'DA-COR-002', 'Corona Encino Nevado con Listón Lino', 'navidad', 'Coronas de encino', 1280.00, NULL, FALSE, 6, TRUE, 'Corona de 55 cm con moño de lino beige para puerta principal.', 'https://images.unsplash.com/photo-1512909006721-3d6018887383?auto=format&fit=crop&w=600&q=80', TRUE);
INSERT INTO productos (id, codigo, nombre, categoria, subcategoria, precio, precio_anterior, en_oferta, stock, es_temporada, descripcion, imagen_url, activo) VALUES (37, 'DA-COR-003', 'Corona Aro Metálico Dorado & Encino', 'navidad', 'Coronas de encino', 890.00, 1050.00, TRUE, 10, TRUE, 'Diseño contemporáneo asimétrico sobre aro fino dorado.', 'https://images.unsplash.com/photo-1576919228236-a097c32a5cd4?auto=format&fit=crop&w=600&q=80', TRUE);
INSERT INTO productos (id, codigo, nombre, categoria, subcategoria, precio, precio_anterior, en_oferta, stock, es_temporada, descripcion, imagen_url, activo) VALUES (38, 'DA-COR-004', 'Corona Encino con Piñas y Luz Cálida', 'navidad', 'Coronas de encino', 1350.00, NULL, FALSE, 5, TRUE, 'Incluye serie de luces cálidas con temporizador automático.', 'https://images.unsplash.com/photo-1544967082-d9d25d867d66?auto=format&fit=crop&w=600&q=80', TRUE);
INSERT INTO productos (id, codigo, nombre, categoria, subcategoria, precio, precio_anterior, en_oferta, stock, es_temporada, descripcion, imagen_url, activo) VALUES (39, 'DA-COR-005', 'Mini Coronas Encino para Sillas (Set x2)', 'navidad', 'Coronas de encino', 640.00, NULL, FALSE, 12, TRUE, 'Par de coronas pequeñas con listón champagne para comedor.', 'https://images.unsplash.com/photo-1511268011861-691ed210aae8?auto=format&fit=crop&w=600&q=80', TRUE);
INSERT INTO productos (id, codigo, nombre, categoria, subcategoria, precio, precio_anterior, en_oferta, stock, es_temporada, descripcion, imagen_url, activo) VALUES (40, 'DA-PEL-001', 'Reno de Peluche Beige & Suéter Tejido', 'navidad', 'Peluches', 580.00, NULL, FALSE, 10, TRUE, 'Peluche decorativo suave en tono crema ideal para pie de árbol o sillón.', 'https://images.unsplash.com/photo-1545048702-79362596cdc9?auto=format&fit=crop&w=600&q=80', TRUE);
INSERT INTO productos (id, codigo, nombre, categoria, subcategoria, precio, precio_anterior, en_oferta, stock, es_temporada, descripcion, imagen_url, activo) VALUES (41, 'DA-PEL-002', 'Oso Polar Blanco con Bufanda Dorada', 'navidad', 'Peluches', 620.00, NULL, FALSE, 8, TRUE, 'Figura suave de oso polar de 35 cm en felpa blanca premium.', 'https://images.unsplash.com/photo-1513297887119-d46091b24bfa?auto=format&fit=crop&w=600&q=80', TRUE);
INSERT INTO productos (id, codigo, nombre, categoria, subcategoria, precio, precio_anterior, en_oferta, stock, es_temporada, descripcion, imagen_url, activo) VALUES (42, 'DA-PEL-003', 'Gnomo Navideño Patas Largas Champagne', 'navidad', 'Peluches', 490.00, 590.00, TRUE, 14, TRUE, 'Gnomo extensible de tela beige y gorro tejido con detalles oro.', 'https://images.unsplash.com/photo-1543589077-47d81606c1bf?auto=format&fit=crop&w=600&q=80', TRUE);
INSERT INTO productos (id, codigo, nombre, categoria, subcategoria, precio, precio_anterior, en_oferta, stock, es_temporada, descripcion, imagen_url, activo) VALUES (43, 'DA-PEL-004', 'Muñeco de Nieve Felpa Arena 40 cm', 'navidad', 'Peluches', 540.00, NULL, FALSE, 9, TRUE, 'Muñeco decorativo con sombrero de tela y botones dorados.', 'https://images.unsplash.com/photo-1512389142860-9c449e58a543?auto=format&fit=crop&w=600&q=80', TRUE);
INSERT INTO productos (id, codigo, nombre, categoria, subcategoria, precio, precio_anterior, en_oferta, stock, es_temporada, descripcion, imagen_url, activo) VALUES (44, 'DA-PEL-005', 'Santa Claus Nórdico Blanco & Oro', 'navidad', 'Peluches', 790.00, NULL, FALSE, 6, TRUE, 'Figura de pie de 50 cm en tonos marfil y dorado elegante.', 'https://images.unsplash.com/photo-1576919228236-a097c32a5cd4?auto=format&fit=crop&w=600&q=80', TRUE);
INSERT INTO productos (id, codigo, nombre, categoria, subcategoria, precio, precio_anterior, en_oferta, stock, es_temporada, descripcion, imagen_url, activo) VALUES (45, 'DA-ELM-001', 'Set de Velas y Portavelas Dorados Navideños', 'navidad', 'Elementos navideños', 520.00, 640.00, TRUE, 14, TRUE, 'Elementos navideños para centro de mesa en cristal y acabado oro.', 'https://images.unsplash.com/photo-1511268011861-691ed210aae8?auto=format&fit=crop&w=600&q=80', TRUE);
INSERT INTO productos (id, codigo, nombre, categoria, subcategoria, precio, precio_anterior, en_oferta, stock, es_temporada, descripcion, imagen_url, activo) VALUES (46, 'DA-ELM-002', 'Punta de Árbol Estrella Calada Dorada', 'navidad', 'Elementos navideños', 450.00, NULL, FALSE, 12, TRUE, 'Estrella metálica ligera en tono oro champagne para coronar el árbol.', 'https://images.unsplash.com/photo-1543589077-47d81606c1bf?auto=format&fit=crop&w=600&q=80', TRUE);
INSERT INTO productos (id, codigo, nombre, categoria, subcategoria, precio, precio_anterior, en_oferta, stock, es_temporada, descripcion, imagen_url, activo) VALUES (47, 'DA-ELM-003', 'Pie de Árbol Tejido Beige Perlado', 'navidad', 'Elementos navideños', 890.00, NULL, FALSE, 7, TRUE, 'Falda circular de 110 cm en punto grueso color crema.', 'https://images.unsplash.com/photo-1544967082-d9d25d867d66?auto=format&fit=crop&w=600&q=80', TRUE);
INSERT INTO productos (id, codigo, nombre, categoria, subcategoria, precio, precio_anterior, en_oferta, stock, es_temporada, descripcion, imagen_url, activo) VALUES (48, 'DA-ELM-004', 'Cascanueces Decorativo Blanco y Oro 38 cm', 'navidad', 'Elementos navideños', 720.00, NULL, FALSE, 8, TRUE, 'Figura clásica de madera pintada en blanco marfil y detalles dorados.', 'https://images.unsplash.com/photo-1545048702-79362596cdc9?auto=format&fit=crop&w=600&q=80', TRUE);
INSERT INTO productos (id, codigo, nombre, categoria, subcategoria, precio, precio_anterior, en_oferta, stock, es_temporada, descripcion, imagen_url, activo) VALUES (49, 'DA-ELM-005', 'Botas Navideñas Lino & Bordado Dorado (Set x2)', 'navidad', 'Elementos navideños', 560.00, NULL, FALSE, 10, TRUE, 'Par de botas navideñas elegantes para colgar en chimenea o pared.', 'https://images.unsplash.com/photo-1512909006721-3d6018887383?auto=format&fit=crop&w=600&q=80', TRUE);
