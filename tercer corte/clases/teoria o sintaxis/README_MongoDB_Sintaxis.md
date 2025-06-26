
# Sintaxis de Consultas en MongoDB

Este archivo documenta la sintaxis, explicación y ejemplos de uso de las consultas más comunes en MongoDB, incluyendo operadores, actualizaciones y agregaciones.

## 1. Inserción de Documentos

```js
db.pokemons.insertOne({
  nombre: "Eevee",
  poder: "Adaptabilidad",
  elemento: "normal",
  nivel_poder: 65,
  altura_m: 0.3,
  peso_kg: 6.5
});
```

📌 Inserta un nuevo documento a la colección `pokemons`.

---

## 2. Consultas Básicas

### Buscar por rango de altura

```js
db.pokemons.find(
  { altura_m: { $gte: 0.5, $lte: 1.7 } },
  { nombre: true, poder: true, elemento: true, _id: false }
);
```
🔍 Busca pokemones cuya altura esté entre 0.5 y 1.7 m y muestra ciertos campos.

### Buscar con AND lógico

```js
db.pokemons.find({
  $and: [
    { altura_m: { $lt: 1 } },
    { peso_kg: { $gt: 5 } }
  ]
}, { nombre: true, altura_m: true, peso_kg: true, _id: false });
```

---

## 3. Operadores Lógicos

### `$or`

```js
db.pokemons.find({
  $or: [
    { nivel_poder: { $lt: 50 } },
    { elemento: "fuego" }
  ]
});
```

### `$not`

```js
db.pokemons.find({
  altura_m: { $not: { $gte: 2 } }
});
```
📌 Busca pokemones cuya altura **no sea mayor o igual a 2**.

### `$nor`

```js
db.pokemons.find({
  $nor: [
    { elemento: "agua" },
    { elemento: "fuego" }
  ]
});
```
📌 Excluye todos los pokemones cuyo elemento sea "agua" o "fuego".

---

## 4. Operadores de Texto (RegEx)

```js
db.pokemons.find({ nombre: /^S/ });    // Empiezan por 'S'
db.pokemons.find({ nombre: /ff$/ });   // Terminan en 'ff'
db.pokemons.find({ nombre: /ba/ });    // Contienen 'ba'
```

---

## 5. Existencia de Campos

```js
db.pokemons.find({ vidas: { $exists: true } });
```

---

## 6. Tipos de Datos

```js
db.pokemons.find({ fechanac: { $type: 'date' } });
```

---

## 7. Operadores de Comparación

```js
db.pokemons.find({
  elemento: { $in: ['agua', 'planta', 'fuego'] }
});
```

```js
db.pokemons.find({
  elemento: { $nin: ['agua', 'planta', 'fuego'] }
});
```

---

## 8. Actualización de Documentos

```js
db.pokemons.updateOne(
  { nombre: "Pikachu" },
  { $set: { nivel_poder: 80 } }
);
```

```js
db.pokemons.updateOne(
  { altura_m: { $lt: 0.5 } },
  { $inc: { altura_m: 0.1 } }
);
```

```js
db.pokemons.updateOne(
  { nombre: "Pikachu" },
  { $unset: { fechanac: true } }
);
```

---

## 9. Arrays y Operadores

```js
db.pokemons.updateOne(
  { nombre: "Pikachu" },
  { $push: { games: "Ruby" } }
);
```

```js
db.pokemons.updateOne(
  { nombre: "Pikachu" },
  { $pull: { games: "Red" } }
);
```

```js
db.pokemons.updateOne(
  { nombre: "Pikachu" },
  { $push: { scores: { $each: [5, 8], $sort: -1 } } }
);
```

---

## 10. Agregación con `$unwind`

```js
db.pokemons.aggregate([
  { $unwind: "$games" },
  { $project: { nombre: 1, games: 1, _id: 0 } }
]);
```
📌 Descompone el array `games` para mostrar cada valor como documento individual.

---

## 11. Lookup (Join)

```js
db.pokemons.aggregate([
  {
    $lookup: {
      from: "species",
      localField: "species_id",
      foreignField: "_id",
      as: "especies"
    }
  }
]);
```

---

## 12. Proyecciones Avanzadas

```js
db.pokemons.findOne(
  { nombre: "Snorlax" },
  { _id: false, nombre: true, games: { $slice: 1 } }
);
```

---

## 13. Agregación con `$map`

```js
db.pokemons.aggregate([
  { $match: { scores: { $exists: true } } },
  {
    $project: {
      nombre: true,
      newScores: {
        $map: {
          input: "$scores",
          as: "score",
          in: { $multiply: ["$$score", 2] }
        }
      }
    }
  }
]);
```

---

## 14. `$findAndModify`

```js
db.pokemons.findAndModify({
  query: { nombre: "Pikachu" },
  update: { $set: { nivel_poder: 100 } },
  new: true
});
```
📌 Actualiza y retorna el nuevo documento.

---

## Fin del resumen de sintaxis.
