-- Crear esquemas
CREATE SCHEMA core;
CREATE SCHEMA participacion;
CREATE SCHEMA facturacion;

-- Tabla core.ubicaciones
CREATE TABLE core.ubicaciones (
    ubicacion_id INT PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
    nombre VARCHAR(100) NOT NULL,
    direccion TEXT NOT NULL,
    ciudad VARCHAR(50) NOT NULL,
    pais VARCHAR(50) NOT NULL,
    capacidad INT,
    descripcion TEXT
);

-- Tabla core.organizadores
CREATE TABLE core.organizadores (
    organizador_id INT PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
    nombre VARCHAR(100) NOT NULL,
    correo_electronico VARCHAR(100) NOT NULL UNIQUE,
    telefono VARCHAR(20),
    sitio_web VARCHAR(150),
    descripcion TEXT
);

-- Tabla core.eventos
CREATE TABLE core.eventos (
    evento_id INT PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
    titulo VARCHAR(150) NOT NULL,
    descripcion TEXT,
    fecha_inicio TIMESTAMP NOT NULL,
    fecha_fin TIMESTAMP,
    capacidad_maxima INT,
    estado VARCHAR(20) CHECK (estado IN ('programado', 'cancelado', 'concluido')),
    creado_en TIMESTAMP DEFAULT now(),
    actualizado_en TIMESTAMP DEFAULT now(),
    ubicacion_id INT NOT NULL REFERENCES core.ubicaciones(ubicacion_id)
);

-- Tabla core.evento_organizadores
CREATE TABLE core.evento_organizadores (
    evento_id INT REFERENCES core.eventos(evento_id),
    organizador_id INT REFERENCES core.organizadores(organizador_id),
    rol VARCHAR(50) DEFAULT 'principal',
    PRIMARY KEY (evento_id, organizador_id)
);

-- Tabla participacion.asistentes
CREATE TABLE participacion.asistentes (
    asistente_id INT PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
    nombre VARCHAR(100) NOT NULL,
    apellido VARCHAR(100) NOT NULL,
    correo_electronico VARCHAR(100) NOT NULL UNIQUE,
    telefono VARCHAR(20),
    fecha_registro TIMESTAMP DEFAULT now()
);

-- Tabla participacion.inscripciones
CREATE TABLE participacion.inscripciones (
    inscripcion_id INT PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
    fecha_inscripcion TIMESTAMP DEFAULT now(),
    estado_inscripcion VARCHAR(20) CHECK (estado_inscripcion IN ('pendiente', 'confirmada', 'cancelada')),
    evento_id INT NOT NULL REFERENCES core.eventos(evento_id),
    asistente_id INT NOT NULL REFERENCES participacion.asistentes(asistente_id)
);

-- Tabla facturacion.pagos
CREATE TABLE facturacion.pagos (
    pago_id INT PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
    monto DECIMAL(10,2) NOT NULL,
    moneda VARCHAR(3) DEFAULT 'USD',
    metodo_pago VARCHAR(50) CHECK (metodo_pago IN ('tarjeta', 'paypal', 'transferencia', 'efectivo')),
    fecha_pago TIMESTAMP DEFAULT now(),
    estado_pago VARCHAR(20) CHECK (estado_pago IN ('pendiente', 'completado', 'reembolsado')),
    inscripcion_id INT NOT NULL REFERENCES participacion.inscripciones(inscripcion_id)
);
