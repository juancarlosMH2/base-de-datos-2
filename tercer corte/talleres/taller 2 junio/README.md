
# Sistema de Triggers en PostgreSQL

Este proyecto implementa tres triggers en PostgreSQL para mantener la integridad y consistencia de los datos en un sistema de gestión de eventos.

## Esquemas utilizados

- `core`: contiene información relacionada con eventos y ubicaciones.
- `participacion`: maneja los asistentes y sus inscripciones.
- `facturacion`: gestiona los pagos realizados por los asistentes.

---

## Triggers implementados

### 1. Actualización automática de la fecha de modificación de eventos

**Esquema:** `core`  
**Tabla:** `eventos`  
**Problema:** No se actualiza la columna `actualizado_en` al modificar un evento.  
**Solución:**  
Trigger `trg_actualizar_fecha_evento` que actualiza la columna `actualizado_en` a la fecha y hora actual (`now()`) cada vez que se hace un `UPDATE`.

```sql
CREATE OR REPLACE FUNCTION core.actualizar_fecha_evento()
RETURNS TRIGGER AS $$
BEGIN
    NEW.actualizado_en := now();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_actualizar_fecha_evento
BEFORE UPDATE ON core.eventos
FOR EACH ROW
EXECUTE FUNCTION core.actualizar_fecha_evento();
```

---

### 2. Validar inscripción única de asistentes

**Esquema:** `participacion`  
**Tabla:** `inscripciones`  
**Problema:** Un asistente puede inscribirse más de una vez al mismo evento.  
**Solución:**  
Trigger `trg_validar_inscripcion` que evita la inserción duplicada validando la combinación `evento_id` y `asistente_id`.

```sql
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
```

---

### 3. Estado por defecto en pagos

**Esquema:** `facturacion`  
**Tabla:** `pagos`  
**Problema:** Si no se especifica el campo `estado_pago`, queda como `NULL`.  
**Solución:**  
Trigger `trg_estado_pago_default` que asigna `'pendiente'` automáticamente si el campo está vacío en la inserción.

```sql
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
```

---

## Instrucciones de prueba

### 1. Crear ubicación y evento de prueba

```sql
INSERT INTO core.ubicaciones (...)
VALUES (...);
```

### 2. Insertar y actualizar evento para verificar el primer trigger

```sql
INSERT INTO core.eventos (...)
VALUES (...);

UPDATE core.eventos
SET titulo = 'Nuevo título'
WHERE evento_id = ...;
```

### 3. Insertar asistente e inscripción válida

```sql
INSERT INTO participacion.asistentes (...);
INSERT INTO participacion.inscripciones (...);
```

### 4. Intentar inscripción duplicada (debe lanzar error)

```sql
-- Esto debe fallar
INSERT INTO participacion.inscripciones (...);
```

### 5. Insertar pago sin especificar estado_pago

```sql
INSERT INTO facturacion.pagos (inscripcion_id, monto, fecha_pago)
VALUES (..., ..., now());
-- El estado será automáticamente 'pendiente'
```

---

## Consideraciones

- Asegúrate de tener creados los esquemas `core`, `participacion` y `facturacion` antes de ejecutar los triggers.
- Los nombres y campos pueden adaptarse según el diseño final de la base de datos.

---

## Autor

Juan Maestre  
Ingeniería de Sistemas – Universidad de Pamplona
