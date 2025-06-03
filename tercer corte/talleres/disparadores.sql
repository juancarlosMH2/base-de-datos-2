--Trigger para actualizar actualizado_en en core.eventos

-- Función del trigger
CREATE OR REPLACE FUNCTION core.actualizar_fecha_evento()
RETURNS TRIGGER AS $$
BEGIN
    NEW.actualizado_en := now();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger
CREATE TRIGGER trg_actualizar_fecha_evento
BEFORE UPDATE ON core.eventos
FOR EACH ROW
EXECUTE FUNCTION core.actualizar_fecha_evento();
--

--

--Trigger para validar que un asistente no 
--se inscriba dos veces al mismo evento

-- Función del trigger
CREATE OR REPLACE FUNCTION participacion.validar_inscripcion()
RETURNS TRIGGER AS $$
BEGIN
    IF EXISTS (
        SELECT 1
        FROM participacion.inscripciones
        WHERE evento_id = NEW.evento_id
          AND asistente_id = NEW.asistente_id
    ) THEN
        RAISE EXCEPTION 'El asistente ya está inscrito en este evento.';
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_validar_inscripcion
BEFORE INSERT ON participacion.inscripciones
FOR EACH ROW
EXECUTE FUNCTION participacion.validar_inscripcion();


 --Trigger para establecer 
 --estado "pendiente" por defecto 
 --en pagos si no se indica

-- Función del trigger
DROP TRIGGER IF EXISTS trg_estado_pago_default ON facturacion.pagos;

CREATE OR REPLACE FUNCTION facturacion.estado_pago_default()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.estado_pago IS NULL THEN
        NEW.estado_pago := 'pendiente';
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_estado_pago_default
BEFORE INSERT ON facturacion.pagos
FOR EACH ROW
EXECUTE FUNCTION facturacion.estado_pago_default();

-- prueba primer disparador

--3. Insertar una ubicación de prueba (si no existe)
INSERT INTO core.ubicaciones (nombre, direccion, ciudad, pais, capacidad, descripcion)
VALUES ('Auditorio Principal', 'Calle 123', 'Pamplona', 'Colombia', 200, 'Auditorio para eventos grandes');

-- 4. Verificar ID de la ubicación insertada (copiar el valor de ubicacion_id si no es 1)
SELECT * FROM core.ubicaciones;

-- 5. Insertar un evento con la ubicación (ajustar ubicacion_id si es necesario)
INSERT INTO core.eventos (titulo, descripcion, fecha_inicio, capacidad_maxima, estado, ubicacion_id)
VALUES ('Prueba de Trigger', 'Evento de prueba', now(), 100, 'programado', 1);

-- 6. Consultar el evento recién insertado
SELECT * FROM core.eventos WHERE titulo = 'Prueba de Trigger';

-- >>> Espera unos segundos para notar el cambio en actualizado_en <<<

-- 7. Actualizar el título del evento (esto debe activar el trigger)
UPDATE core.eventos
SET titulo = 'Prueba de Trigger Actualizado'
WHERE titulo = 'Prueba de Trigger';

-- 8. Consultar nuevamente para verificar si 'actualizado_en' cambió
SELECT * FROM core.eventos WHERE titulo = 'Prueba de Trigger Actualizado';

-- segundo disparador

-- 1. Crear ubicación si no existe (verifica por nombre)
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM core.ubicaciones WHERE nombre = 'Salón 101'
    ) THEN
        INSERT INTO core.ubicaciones (nombre, direccion, ciudad, pais, capacidad, descripcion)
        VALUES ('Salón 101', 'Carrera 5 #10-20', 'Pamplona', 'Colombia', 50, 'Salón para eventos académicos');
    END IF;
END $$;

-- 2. Obtener ID de ubicación
SELECT ubicacion_id FROM core.ubicaciones WHERE nombre = 'Salón 101';

-- Suponiendo que ubicacion_id es 2

-- 3. Crear evento si no existe
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM core.eventos WHERE titulo = 'Seminario de Tecnología'
    ) THEN
        INSERT INTO core.eventos (titulo, descripcion, fecha_inicio, capacidad_maxima, estado, ubicacion_id)
        VALUES ('Seminario de Tecnología', 'Charla sobre IA', now(), 50, 'programado', 2);
    END IF;
END $$;

-- 4. Obtener ID del evento
SELECT evento_id FROM core.eventos WHERE titulo = 'Seminario de Tecnología';

-- Supongamos que evento_id es 3

-- 5. Insertar asistente solo si no existe
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM participacion.asistentes WHERE correo_electronico = 'juan.perez@email.com'
    ) THEN
        INSERT INTO participacion.asistentes (nombre, apellido, correo_electronico)
        VALUES ('Juan', 'Pérez', 'juan.perez@email.com');
    END IF;
END $$;

-- 6. Obtener ID del asistente
SELECT asistente_id FROM participacion.asistentes WHERE correo_electronico = 'juan.perez@email.com';

-- Supongamos que asistente_id es 1

-- 7. Inscripción válida
SELECT * FROM core.eventos WHERE evento_id = 3;
-- o si no usas esquemas:

-- Inserta un evento válido
INSERT INTO core.eventos (titulo, descripcion, fecha_inicio, capacidad_maxima, estado, ubicacion_id)
VALUES ('Conferencia IA', 'Evento sobre inteligencia artificial', now(), 100, 'programado', 1);

-- Verifica el ID insertado
SELECT * FROM core.eventos ORDER BY evento_id DESC LIMIT 1;



INSERT INTO participacion.inscripciones (evento_id, asistente_id)
VALUES (3, 1);

-- 8. Inscripción duplicada (debe fallar por el trigger)
INSERT INTO participacion.inscripciones (evento_id, asistente_id)
VALUES (3, 1);


-- tercer disparador 

--Verifica una inscripción válida
--Primero asegúrate de tener una inscripcion_id válida en participacion.inscripciones.


SELECT inscripcion_id FROM participacion.inscripciones LIMIT 1;
--Supongamos que obtienes: inscripcion_id = 1.

DO $$
DECLARE
  id_evento INT;
  id_asistente INT;
  id_inscripcion INT;
BEGIN
  -- 1. Asegurarse de que exista el evento
  SELECT evento_id INTO id_evento FROM core.eventos WHERE titulo = 'Seminario de Tecnología' LIMIT 1;
  IF id_evento IS NULL THEN
    INSERT INTO core.eventos (titulo, descripcion, fecha_inicio, capacidad_maxima, estado, ubicacion_id)
    VALUES ('Seminario de Tecnología', 'Charla sobre IA', now(), 50, 'programado', 1)
    RETURNING evento_id INTO id_evento;
  END IF;

  -- 2. Asegurarse de que exista el asistente
  SELECT asistente_id INTO id_asistente FROM participacion.asistentes WHERE correo_electronico = 'juan.perez@email.com' LIMIT 1;
  IF id_asistente IS NULL THEN
    INSERT INTO participacion.asistentes (nombre, apellido, correo_electronico)
    VALUES ('Juan', 'Pérez', 'juan.perez@email.com')
    RETURNING asistente_id INTO id_asistente;
  END IF;

  -- 3. Asegurar inscripción única
  SELECT inscripcion_id INTO id_inscripcion
  FROM participacion.inscripciones
  WHERE evento_id = id_evento AND asistente_id = id_asistente;

  IF id_inscripcion IS NULL THEN
    INSERT INTO participacion.inscripciones (evento_id, asistente_id)
    VALUES (id_evento, id_asistente)
    RETURNING inscripcion_id INTO id_inscripcion;
  END IF;

  -- 4. Insertar el pago SIN estado_pago (aquí se activa el trigger)
  INSERT INTO facturacion.pagos (inscripcion_id, monto, fecha_pago)
  VALUES (id_inscripcion, 50000, now());

  RAISE NOTICE 'Pago insertado correctamente para inscripcion_id=%', id_inscripcion;
END $$;

SELECT * FROM facturacion.pagos
ORDER BY pago_id DESC
LIMIT 1;





