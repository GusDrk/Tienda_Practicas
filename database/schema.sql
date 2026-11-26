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
