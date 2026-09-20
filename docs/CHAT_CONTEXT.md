# Finanpolis — Contexto para chats con IA

> Pegá o adjuntá este archivo al empezar un chat nuevo. Se mantiene al día junto con `MEETING_NOTES.md`.
> Si algo cambia en el proyecto, actualizalo antes de cerrar el chat.

## Proyecto

- **Finanpolis**: juego de simulación de vida (tipo life-sim) para educación financiera.
- Motor: **Godot 4.7**, lenguaje **GDScript**. Vista **isométrica 2:1**, arte **pixel art** (todavía sin imágenes).
- Repo: https://codeberg.org/Monetas/Dev-Finanpolis (equipo con varios colaboradores).
- Arquitectura y pasos de construcción: ver `README.md` del repo. Regla clave: hacer que **una interacción completa** funcione de punta a punta antes de sumar más cosas.

## Reglas de trabajo

1. **Código en inglés** (variables, clases, funciones, nodos, archivos). **Comentarios en español coloquial argentino**, cortos y simples: son referencia, lo importante se discute en reuniones.
2. Estructura de carpetas: `Scenes/`, `Scripts/` (con `state_machine/` y `utilities/`), `Assets/`, `Data/`.
3. Nombres de archivos en `snake_case`; clases en `PascalCase`.
4. Comunicación entre escenas: **llamadas hacia abajo, señales hacia arriba**. Nadie toca los estados desde afuera; se le pide al Player (`move_to`, `interact_with`).
5. Godot 4.7 está en `~/Descargas/Godot v4.7` (se puede correr con `--headless --path .` para validar).
6. Usar placeholders (formas de colores) hasta que haya arte.
7. No hacer commit ni push sin que el usuario lo pida.
8. Después de cada cambio importante, actualizar `docs/MEETING_NOTES.md` y este archivo.

## Estado actual del juego

**Funciona (probado en headless con Godot 4.7, falta prueba manual con ventana):** click en el piso → el Player camina; click en un objeto → camina y lo usa.

### Estructura de archivos

```
Scenes/
  player.tscn            CharacterBody2D + Sprite (AnimatedSprite2D) + StateMachine (Idle, Moving, Interacting)
  usable_object.tscn     Area2D + CollisionShape2D + StandPoint + UsePoint
  world.tscn             Mundo de prueba (escena principal): UsableObjects (Bed, Chair, Computer), Player, Camera2D
Scripts/
  player.gd              class Player: move_to(), interact_with(), stop(), play_animation(), señales
  usable_object.gd       class UsableObject: describe cómo se usa (animation, facing, duration, puntos)
  world.gd               Traduce clicks en órdenes y hace que la cámara siga al Player
  state_machine/
    state.gd             class State: base (enter(msg), exit(), physics_update(delta))
    state_machine.gd     class StateMachine: switch_state(name, msg), señal state_changed
    idle.gd  moving.gd  interacting.gd
  utilities/
    coordinate_utils.gd  class CoordinateUtils: iso_velocity(), direction_name()
```

### Player y su máquina de estados

- Estados (nodos hijos de `StateMachine`, se buscan por nombre en minúsculas): `idle`, `moving`, `interacting`.
- `moving` recibe `{target, usable?}`; al llegar va a `interacting` si había un objeto, o a `idle`. Tiene anti-atasco.
- `interacting` recibe `{usable}`: pide el objeto (`begin_interaction`), acomoda al Player en `get_use_position()`, reproduce la animación y, si `duration > 0`, termina solo. Al salir lo deja en `get_stand_position()`.
- Señales del Player: `arrived`, `interaction_started(usable)`, `interaction_finished(usable)`, `state_changed(name)`.
- Señales del UsableObject: `requested(usable)` (click), `interaction_started(player)`, `interaction_finished(player)`.

### Convenciones de animación

`play_animation("walk")` busca `walk_<dir>` (dir ∈ e, se, s, sw, w, nw, n, ne) y si no existe prueba `walk`. Si no hay `SpriteFrames` con esa animación, no hace nada. Animaciones esperadas: `idle`, `walk`, `sit`, `sleep`, `use_computer`.

### Isométrico

`CoordinateUtils.iso_velocity` compensa el eje Y (ratio 0.5). Por ahora el movimiento es en línea recta, sin navegación.

## Pendiente

- Probar a mano con ventana (F5).
- TileMap isométrico + `NavigationAgent2D`.
- Sistema de necesidades (empezar por energía) enganchado a las señales de los objetos.
- TimeManager y HUD (necesidades + hora).
- Sprites reales y lista de animaciones.
- Guardado/carga (recién cuando el loop básico ande).
- Inicializar git y conectar con Codeberg.

## Preguntas abiertas

- ¿Qué pasa si se interrumpe una interacción a la mitad?
- ¿Los efectos de cada objeto (energía, plata) van en el objeto o en archivos de `Data/`?
- Tamaño y formato definitivo de los sprites.
