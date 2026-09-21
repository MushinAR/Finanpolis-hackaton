# Guía de arte (para reemplazar los placeholders)

Todo lo que hay hoy en esta carpeta es **provisorio** y está pensado para reemplazarse **soltando los PNG nuevos con el mismo nombre**. No hace falta tocar escenas ni código.

## Reglas generales

- Tamaño de celda: **64×64 px**, con fondo transparente. Si el equipo cambia el tamaño, se ajusta en un solo lugar (ver "Si cambia el tamaño").
- Vista isométrica 2:1: el rombo del piso mide **64×32 px** y va en la **mitad de abajo** de la imagen.
- **Punto de apoyo en el píxel (32, 48)** de cada imagen: es el centro del rombo. Los pies del personaje y la base de cada objeto van ahí.
- Todo sin suavizado (pixel art puro).

## Tileset — `tilesets/tileset.png`

Imagen de 128×64 con dos tiles de 64×64, de izquierda a derecha:

| Posición | Tile | Notas |
|---|---|---|
| 0 | Piso | Rombo en la mitad de abajo |
| 1 | Pared | Cubo: el rombo de la base en la mitad de abajo y las caras subiendo |

Para sumar tiles nuevos, agregarlos a la derecha en la misma imagen y crearlos en `tileset.tres` desde el editor de Godot. Si el tile bloquea el paso, hay que dibujarle la colisión en la capa de física.

## Props — `sprites/props/*.png`

Un PNG de 64×64 por objeto: `bed`, `chair`, `trash_bin` y `crate` (caja obstáculo). Los que cambian de estado tienen una imagen por estado: `computer_off`, `computer_booting`, `computer_on` `lamp_off`, `lamp_on` y `switch_off`, `switch_on` (interruptor de la pared). Objetos más grandes que un tile se pueden dibujar más grandes; avisar para ajustar el punto de apoyo y la colisión.

## Luces — `lights/light_soft.tres`

Degradé radial que usan todas las luces. Si el arte necesita otro estilo de luz, se reemplaza este recurso (o se asigna otra textura a la luz).

## Items — `sprites/items/*.png`

Cosas que el jugador carga: `book.png`, `pizza_box.png` y `dirty_shirt.png`. 64×64, con la base en el píxel (32, 48). Cuando el Player los lleva, aparecen sobre su cabeza (esa posición se ajusta en el nodo `CarrySlot` de `player.tscn`).

## Player — `sprites/player/player_<animación>_<dirección>.png`

Cada archivo es una **tira horizontal** de cuadros de 64×64. La cantidad de cuadros sale sola del ancho de la imagen (1 cuadro = 64 px de ancho, 4 cuadros = 256 px).

- **Animaciones hoy:** `idle`, `walk`, `sit`, `sleep`, `use_computer`.
- **Direcciones hoy (4):** `se`, `sw`, `nw`, `ne`.
- Si falta un archivo, el juego no falla: esa animación simplemente no se ve.

Placeholder actual: idle 1 cuadro, walk 4, sit 1, sleep 1, use_computer 2.

## Si cambia el tamaño o la cantidad de direcciones

Todo se configura en `Data/player_config.tres` (desde el inspector de Godot): tamaño de cuadro, 4 u 8 direcciones, velocidad de cada animación y carpeta. Para sumar una animación nueva, agregarla ahí y soltar los PNG.
El tamaño del tile es el de `tilesets/tileset.tres` (Tile Size). Se asume siempre proporción 2:1.

