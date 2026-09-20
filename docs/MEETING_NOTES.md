# Finanpolis — Apuntes para reuniones

> Documento de trabajo de Jmgoya y Claude. Lo actualizamos entre los dos después de cada cambio importante.
> Sirve para llegar a las reuniones sabiendo qué hay hecho, qué decidimos y qué falta discutir.

**Última actualización:** 2026-09-20

## Qué hay hoy (resumen rápido)

- El jugador hace click en el piso y el Player camina hasta ahí.
- El jugador hace click en un objeto (cama, silla, compu), el Player camina hasta él y lo usa.
- Todo lo maneja una máquina de estados dentro del Player: `idle`, `moving`, `interacting`.
- Todavía **no hay arte**: todo se dibuja con formas provisorias (círculos y rombos de colores).
- Probado con una corrida sin ventana (headless) en Godot 4.7: camina, usa cama y compu y se levanta bien. **Falta probarlo a mano con ventana.**

## Cómo funciona (para explicarlo en la reunión)

1. **World** recibe el click. Si fue en el piso, le dice al Player `move_to(punto)`. Si fue sobre un objeto, el objeto avisa con una señal y el World le dice al Player `interact_with(objeto)`.
2. **Player** no decide nada por sí mismo: le pasa la orden a su **StateMachine**.
3. **StateMachine** cambia de estado:
   - `idle`: parado.
   - `moving`: camina al destino. Si iba a un objeto, al llegar pasa a `interacting`.
   - `interacting`: se sube al objeto (se sienta, se acuesta, usa la compu) y se queda hasta que termina el tiempo o el jugador hace click en otro lado.
4. Cada **UsableObject** describe cómo se usa: qué animación, para dónde mira, cuánto dura y dónde se para el jugador. Por eso alcanza con un solo estado `interacting` para todos los objetos.

## Decisiones tomadas

| Tema | Decisión | Por qué |
|---|---|---|
| Comunicación entre escenas | Las órdenes bajan con llamadas, los avisos suben con señales | Así el Player no conoce al resto del juego y se puede enganchar HUD, tiempo y necesidades sin tocar los estados |
| Estados de interacción | Un solo `interacting` para todos los objetos | Evita un estado por cada objeto; cada objeto trae sus datos |
| Nombre de los objetos usables | `UsableObject` (antes `Interactable`) | Pedido de Jmgoya. Fácil de cambiar si sale algo mejor en la reunión |
| Movimiento isométrico | Se compensa la velocidad para que ir en vertical no se vea el doble de rápido | Vista isométrica 2:1 |
| Animaciones | Nombre `accion_direccion` (ej. `walk_se`), 8 direcciones | Para cuando llegue el pixel art |
| Cámara | Vive en el World, no en el Player | Así lo muestra el diagrama del README |
| Idioma | Código en inglés, comentarios en español coloquial | Pedido de Jmgoya |

## Historial de cambios

### 2026-09-20
- Reorganizamos el proyecto según el README (`Scenes/`, `Scripts/`, `Assets/`, `Data/`).
- `Personaje` pasó a `Player`; `caminando` a `moving`. Se borró la plantilla `ejemplo`.
- Máquina de estados ampliada: `enter(msg)` recibe datos, señal `state_changed`, `physics_update` en cada estado.
- Creados los estados `moving` e `interacting`.
- Creado el objeto usable y el `world.tscn` de prueba con Cama, Silla y Computadora.
- Se arregló el warning del `AnimatedSprite2D` (le pusimos un `SpriteFrames` vacío).
- `Interactable` renombrado a `UsableObject`; comentarios reescritos más simples y coloquiales.
- Agregados este documento y `CHAT_CONTEXT.md`.
- Primera corrida headless: bug arreglado (la StateMachine arrancaba antes de que el Player tuviera su sprite; ahora espera a que el Player esté listo).

## Pendiente / para discutir en reuniones

- [ ] Probar a mano con ventana (F5) y ver cómo se siente.
- [ ] TileMap isométrico y navegación (`NavigationAgent2D`) para esquivar obstáculos.
- [ ] Primera necesidad (energía) enganchada a las señales de los objetos (la cama la recupera).
- [ ] TimeManager y HUD básico.
- [ ] Definir cómo van a ser los sprites: tamaño, direcciones, lista de animaciones.
- [ ] ¿Qué pasa si el jugador interrumpe una interacción a la mitad? (hoy se levanta y se va)
- [ ] ¿El costo/efecto de cada objeto va en el propio objeto o en un archivo de `Data/`?
- [ ] Repo en Codeberg: todavía no está inicializado git en esta carpeta.
