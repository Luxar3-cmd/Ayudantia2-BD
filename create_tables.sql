-- Tabla de sucursales
CREATE TABLE sucursal (
    ID_sucursal SERIAL PRIMARY KEY,
    tipo VARCHAR(2) NOT NULL UNIQUE, -- Con valores “A”, “B”, “C”. Se usa VARCHAR(2) para mayor seguridad
    ciudad VARCHAR(50) NOT NULL
);

-- Tabla de clientes
CREATE TABLE cliente (
    ID_cliente SERIAL PRIMARY KEY,
    tipo_cliente VARCHAR(50) NOT NULL,
    genero VARCHAR(6) NOT NULL
);

-- Tabla de productos
CREATE TABLE producto (
    ID_producto SERIAL PRIMARY KEY,
    linea_producto VARCHAR(50) NOT NULL UNIQUE
);

-- Tabla de boletas
CREATE TABLE boleta (
    ID_boleta VARCHAR(20) NOT NULL UNIQUE,
    ID_cliente INTEGER NOT NULL,
    ID_sucursal INTEGER NOT NULL,
    fecha DATE NOT NULL,
    hora TIME NOT NULL,
    tipo_pago VARCHAR(50) NOT NULL,
    calificacion NUMERIC,  -- Puedes ajustar precisión, por ejemplo NUMERIC(3,1)
    CONSTRAINT fk_boleta_cliente FOREIGN KEY (ID_cliente) REFERENCES cliente(ID_cliente),
    CONSTRAINT fk_boleta_sucursal FOREIGN KEY (ID_sucursal) REFERENCES sucursal(ID_sucursal)
);

-- Tabla de ventas
CREATE TABLE venta (
    ID_boleta VARCHAR(20) NOT NULL UNIQUE,
    ID_producto INTEGER NOT NULL,
    precio_unitario DECIMAL(10,2) NOT NULL,
    cantidad INTEGER NOT NULL,
    total DECIMAL(10,2) NOT NULL,
    impuesto DECIMAL(10,2) NOT NULL,
    PRIMARY KEY(ID_boleta, ID_producto),
    CONSTRAINT fk_venta_boleta FOREIGN KEY (ID_boleta) REFERENCES boleta(ID_boleta),
    CONSTRAINT fk_venta_producto FOREIGN KEY (ID_producto) REFERENCES producto(ID_producto)
);
