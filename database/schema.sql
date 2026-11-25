-- ============================================================================
-- Base de Datos: DecorArte
-- Descripción: Esquema inicial para catálogo, clientes, pedidos y pagos con
--              Mercado Pago (listo para importar en Oracle Cloud / MySQL / PostgreSQL).
-- ============================================================================

CREATE TABLE productos (
    id              INT PRIMARY KEY,
    nombre          VARCHAR(150) NOT NULL,
    categoria       VARCHAR(50) NOT NULL, -- 'cuadros', 'espejos', 'mesas', 'ceramica', 'navidad'
    precio          DECIMAL(10, 2) NOT NULL,
    stock           INT NOT NULL DEFAULT 0,
    es_temporada    BOOLEAN NOT NULL DEFAULT FALSE,
    descripcion     TEXT,
    imagen_url      VARCHAR(500),
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
    tipo_entrega    VARCHAR(30) NOT NULL, -- 'tienda' (recoger en tienda) | 'domicilio'
    metodo_pago     VARCHAR(40) NOT NULL, -- 'mercadopago_online' | 'mercadopago_terminal'
    estado          VARCHAR(30) NOT NULL DEFAULT 'pendiente', -- 'pendiente', 'pagado', 'listo', 'entregado', 'cancelado'
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
    mp_payment_id       VARCHAR(100), -- ID de pago devuelto por Mercado Pago / Terminal Point
    mp_preference_id    VARCHAR(100), -- ID de preferencia Checkout Pro (si aplica)
    estado_pago         VARCHAR(40) NOT NULL DEFAULT 'pendiente',
    monto               DECIMAL(10, 2) NOT NULL,
    actualizado_en      TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (pedido_id) REFERENCES pedidos(id)
);

-- ============================================================================
-- Datos iniciales de ejemplo (Catálogo DecorArte)
-- ============================================================================
INSERT INTO productos (id, nombre, categoria, precio, stock, es_temporada, descripcion) VALUES
(1, 'Cuadro Abstracto Dorado & Mármol', 'cuadros', 1850.00, 5, FALSE, 'Lienzo enmarcado en acabado dorado cepillado.'),
(2, 'Espejo Circular Marco Dorado', 'espejos', 2400.00, 3, FALSE, 'Espejo de 80 cm con marco metálico champagne dorado.'),
(3, 'Mesa Auxiliar de Cristal y Latón', 'mesas', 3200.00, 4, FALSE, 'Mesa pequeña con cubierta de cristal templado y base dorada.'),
(4, 'Figura de Cerámica Orgánica Beige', 'ceramica', 680.00, 10, FALSE, 'Escultura decorativa de cerámica mate en tono arena.'),
(5, 'Set de 3 Jarrones Cerámica Minimal', 'ceramica', 950.00, 6, FALSE, 'Trío de piezas en cerámica beige y blanco hueso.'),
(6, 'Corona Navideña Dorada & Pino', 'navidad', 1150.00, 8, TRUE, 'Corona artesanal de temporada con detalles dorados.'),
(7, 'Esferas de Cristal y Hoja de Oro (Set x6)', 'navidad', 790.00, 12, TRUE, 'Juego de 6 esferas navideñas elegantes.'),
(8, 'Espejo Arco de Cuerpo Completo', 'espejos', 4100.00, 2, FALSE, 'Espejo estilo arco con borde fino dorado.');
