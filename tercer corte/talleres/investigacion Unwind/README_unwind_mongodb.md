
# Uso de `$unwind` en MongoDB

## 📘 ¿Qué es `$unwind`?

El operador `$unwind` es una etapa del *pipeline* de agregación en MongoDB que permite descomponer un array contenido en un documento en múltiples documentos individuales. Cada elemento del array se convierte en un nuevo documento en la salida del *pipeline*.

### 📌 Sintaxis básica

```js
{ $unwind: "$nombreDelArray" }
```

### 🧪 Ejemplo básico

```js
db.usuarios.aggregate([
  { $unwind: "$intereses" }
])
```

Si un documento tiene el array `["cine", "música", "deporte"]`, se dividirá en tres documentos:

```json
{ "nombre": "Ana", "intereses": "cine" }
{ "nombre": "Ana", "intereses": "música" }
{ "nombre": "Ana", "intereses": "deporte" }
```

---

## ⚙️ Opciones avanzadas

MongoDB ofrece personalización adicional con:

- `preserveNullAndEmptyArrays`: Si es `true`, los documentos con arrays nulos o vacíos no se descartan.
- `includeArrayIndex`: Guarda el índice del elemento dentro del array.

### 🧪 Ejemplo avanzado

```js
db.usuarios.aggregate([
  {
    $unwind: {
      path: "$intereses",
      preserveNullAndEmptyArrays: true,
      includeArrayIndex: "indice"
    }
  }
])
```

Esto añade un campo `"indice"` que representa la posición del elemento en el array.

---

## 🎯 ¿Para qué sirve `$unwind`?

- Agrupar o hacer estadísticas por elementos individuales de un array.
- Filtrar o transformar valores específicos dentro de un array.
- Combinar datos con otras colecciones mediante `$lookup` después de descomponer el array.

---

## 📝 Ejercicios prácticos

### ✅ Ejercicio 1: Descomposición simple

**Colección `clientes`**:

```json
{ "nombre": "Luis", "compras": ["pan", "leche", "huevos"] }
```

**Tarea:** Usa `$unwind` para que cada compra aparezca en un documento separado.

```js
db.clientes.aggregate([
  { $unwind: "$compras" }
])
```

---

### ✅ Ejercicio 2: Uso de `includeArrayIndex`

**Tarea:** Modifica el ejercicio anterior para que también se incluya el índice de la compra.

```js
db.clientes.aggregate([
  {
    $unwind: {
      path: "$compras",
      includeArrayIndex: "posicion"
    }
  }
])
```

---

### ✅ Ejercicio 3: Combinación con `$group`

**Tarea:** Cuenta cuántas veces aparece cada artículo en las compras de todos los clientes.

```js
db.clientes.aggregate([
  { $unwind: "$compras" },
  {
    $group: {
      _id: "$compras",
      total: { $sum: 1 }
    }
  }
])
```

---

### ✅ Ejercicio 4: Conservar documentos sin compras

**Documento con array vacío:**

```json
{ "nombre": "Carlos", "compras": [] }
```

**Tarea:** Asegúrate de conservar este documento en la salida.

```js
db.clientes.aggregate([
  {
    $unwind: {
      path: "$compras",
      preserveNullAndEmptyArrays: true
    }
  }
])
```

---

## 📌 Conclusión

El operador `$unwind` es una herramienta poderosa para trabajar con arrays en MongoDB. Permite explotar al máximo los datos estructurados y facilita su análisis y transformación. Su uso combinado con otros operadores como `$group`, `$project` y `$lookup` lo convierte en un componente clave en cualquier pipeline de agregación.

---

## 📚 Referencias

- [MongoDB Aggregation Documentation](https://www.mongodb.com/docs/manual/meta/aggregation-quick-reference/)
- [Operador `$unwind`](https://www.mongodb.com/docs/manual/reference/operator/aggregation/unwind/)
