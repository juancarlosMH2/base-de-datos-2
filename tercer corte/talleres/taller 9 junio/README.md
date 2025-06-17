# 📚 Base de Datos MongoDB - Operadores Lógicos y de Comparación

Este proyecto crea una base de datos en MongoDB llamada `operadoresDB` que contiene una colección llamada `operadores`. En ella se almacenan los operadores **lógicos**, **de comparación** y sus **combinaciones** comunes en MongoDB, junto con su descripción y sintaxis.

---

## 📦 Estructura del Documento

Cada documento en la colección `operadores` contiene:

- `nombre`: Nombre del operador (ej. `$and`, `$eq`, etc.)
- `tipo`: Tipo de operador (`lógico`, `comparación`, `combinación`)
- `descripcion`: Explicación breve del operador
- `sintaxis`: Ejemplo de uso del operador en formato MongoDB

---

## 🛠️ Cómo usar

### 1. Abre tu consola de MongoDB (`mongosh`) e ingresa:

```js
use operadoresDB;
```

---

### 2. Inserta los datos en la colección:

```js
db.operadores.insertMany([
  {
    nombre: "$eq",
    tipo: "comparación",
    descripcion: "Igual a (Equal). Devuelve true si los valores son iguales.",
    sintaxis: "{ campo: { $eq: valor } }"
  },
  {
    nombre: "$ne",
    tipo: "comparación",
    descripcion: "No igual a (Not Equal).",
    sintaxis: "{ campo: { $ne: valor } }"
  },
  {
    nombre: "$gt",
    tipo: "comparación",
    descripcion: "Mayor que.",
    sintaxis: "{ campo: { $gt: valor } }"
  },
  {
    nombre: "$and",
    tipo: "lógico",
    descripcion: "Devuelve true si todas las condiciones son verdaderas.",
    sintaxis: "{ $and: [ { campo1: valor1 }, { campo2: valor2 } ] }"
  },
  {
    nombre: "$or",
    tipo: "lógico",
    descripcion: "Devuelve true si alguna condición se cumple.",
    sintaxis: "{ $or: [ { campo1: valor1 }, { campo2: valor2 } ] }"
  },
  {
    nombre: "$and + $gt + $lt",
    tipo: "combinación",
    descripcion: "Campo entre dos valores.",
    sintaxis: "{ $and: [ { campo: { $gt: 5 } }, { campo: { $lt: 10 } } ] }"
  }
]);
```

---

## 🔍 Consultas útiles

### Mostrar todos los operadores:
```js
db.operadores.find().pretty();
```

### Mostrar solo operadores lógicos:
```js
db.operadores.find({ tipo: "lógico" }).pretty();
```

### Mostrar operadores de comparación:
```js
db.operadores.find({ tipo: "comparación" }).pretty();
```

### Mostrar combinaciones:
```js
db.operadores.find({ tipo: "combinación" }).pretty();
```

### Buscar por nombre de operador:
```js
db.operadores.find({ nombre: "$and" }).pretty();
```

### Buscar operadores que contengan `$in` en su sintaxis:
```js
db.operadores.find({ sintaxis: /.*\$in.*/ }).pretty();
```

### Mostrar solo `nombre` y `descripcion`:
```js
db.operadores.find({}, { _id: 0, nombre: 1, descripcion: 1 });
```

### Contar operadores por tipo:
```js
db.operadores.aggregate([
  { $group: { _id: "$tipo", total: { $sum: 1 } } }
]);
```

---

## ✅ Requisitos

- MongoDB instalado
- Acceso a `mongosh` o a MongoDB Compass
- Conocimientos básicos de consultas en MongoDB

---

## ✍️ Autor

Juan Maestre

---

## 📌 Notas

Puedes extender la base de datos agregando nuevos operadores, ejemplos avanzados o incluso añadir un campo `ejemplo_uso` para tener un caso práctico más claro.
