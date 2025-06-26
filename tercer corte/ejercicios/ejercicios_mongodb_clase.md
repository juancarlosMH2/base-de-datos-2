# 📘 Ejercicios Clave de MongoDB - Colección Pokémons

Este documento resume los ejercicios más relevantes de distintos temas relacionados con consultas y operaciones en MongoDB, aplicados a una colección de Pokémons. Ideal para estudiar para un examen o repasar los conceptos clave.

---

## 🔍 1. Búsqueda por Rangos

Consulta Pokémons cuya altura esté entre 0.5 y 1.7 metros:

```js
db.pokemons.find(
  { altura_m: { $gte: 0.5, $lte: 1.7 } },
  { nombre: true, poder: true, elemento: true, _id: false }
)
```

---

## 🧩 2. Búsquedas Combinadas ($and, $or)

### Ejemplo con `$and`:
Pokémons con altura < 1 metro y peso > 5kg:

```js
db.pokemons.find({
  $and: [
    { altura_m: { $lt: 1 } },
    { peso_kg: { $gt: 5 } }
]}, {
  nombre: true, altura_m: true, peso_kg: true, _id: false
})
```

### Ejemplo con `$or`:
Pokémons de tipo fuego o con poder < 50:

```js
db.pokemons.find({
  $or: [
    { nivel_poder: { $lt: 50 } },
    { elemento: "fuego" }
]}, {
  nombre: true, elemento: true, nivel_poder: true
})
```

---

## 🔤 3. Búsqueda por Patrones (RegEx)

```js
db.pokemons.find({ nombre: /^S/ })   // Comienza con S
db.pokemons.find({ nombre: /ff$/ })  // Termina con "ff"
db.pokemons.find({ nombre: /ba/ })   // Contiene "ba"
```

---

## 🧪 4. Verificación de Campos y Tipos

### ¿Tiene el campo `vidas`?
```js
db.pokemons.find({ vidas: { $exists: true } })
```

### ¿Campo `fechanac` es de tipo fecha?
```js
db.pokemons.find({ fechanac: { $type: "date" } })
```

---

## 🛠 5. Actualizaciones (UpdateOne)

### Modificar un campo:
```js
db.pokemons.updateOne({ elemento: "normal" }, { $set: { peso_kg: 46 } })
```

### Incrementar un valor:
```js
db.pokemons.updateOne({ altura_m: { $lt: 0.5 } }, { $inc: { altura_m: 0.1 } })
```

### Eliminar un campo:
```js
db.pokemons.updateOne({ fechanac: { $exists: true } }, { $unset: { fechanac: true } })
```

### Insertar si no existe (upsert):
```js
db.pokemons.updateOne({ nombre: "charmander" }, { $set: { elemento: "fuego" } }, { upsert: true })
```

---

## 🔄 6. findAndModify

Modifica y retorna el Pokémon actualizado:

```js
db.pokemons.findAndModify({
  query: { nombre: "Pikachu" },
  update: { $set: { nivel_poder: 70 } },
  new: true
})
```

---

## 🧮 7. Operadores $in y $nin

### Están en la lista:
```js
db.pokemons.find({ elemento: { $in: ["fuego", "planta", "agua"] } })
```

### No están en la lista:
```js
db.pokemons.find({ elemento: { $nin: ["fuego", "planta", "agua"] } })
```

---

## 📚 8. Manejo de Arrays

### Agregar juego:
```js
db.pokemons.updateOne({ nombre: "Bulbasaur" }, { $push: { games: "Yellow" } })
```

### Eliminar un juego:
```js
db.pokemons.updateOne({ nombre: "Bulbasaur" }, { $pull: { games: "Ruby" } })
```

### Visualizar parte del array:
```js
db.pokemons.findOne({ nombre: "Snorlax" }, { _id: false, nombre: true, games: { $slice: 1 } })
```

---

## 🧬 9. Documentos Anidados

### Insertar stats:
```js
db.pokemons.insertOne({
  nombre: "Pikachu",
  tipo: "eléctrico",
  stats: { ataque: 55, defensa: 40, velocidad: 90 }
})
```

### Consultar stats:
```js
db.pokemons.find({ "stats.velocidad": { $gt: 80 } })
```

### Actualizar stats:
```js
db.pokemons.updateOne({ nombre: "Pikachu" }, { $set: { "stats.ataque": 60 } })
```

---

## 📊 10. Agregaciones

### Mostrar scores de un Pokémon:
```js
db.pokemons.aggregate([
  { $match: { scores: { $exists: true } } },
  { $project: { _id: false, nombre: true, scores: true } },
  { $limit: 1 }
])
```

### Transformar scores:
```js
db.pokemons.aggregate([
  { $match: { scores: { $exists: true } } },
  { $project: {
      nombre: true,
      newScores: { $map: {
        input: "$scores",
        as: "score",
        in: { $multiply: ["$$score", 5] }
      }}
    }
  }
])
```

---

## 🧠 Notas Finales

- Utiliza `$match`, `$project`, `$group`, `$lookup`, `$unwind` para agregaciones avanzadas.
- Aprende a manejar documentos anidados y arrays para estructuras complejas.
- Revisa los operadores `$set`, `$inc`, `$unset`, `$push`, `$pull`, `$each`, `$map`, entre otros.

---
📅 **Última actualización:** junio 2025