class_name PlayerConfig
extends Resource
## Configuración del Player. Los valores viven en Data/player_config.tres.

## Velocidad sobre el piso, en px/s.
@export var speed: float = 300.0
## Cuántas direcciones tiene el arte: 4 (se, sw, nw, ne) u 8 (suma e, s, w, n).
@export_enum("4", "8") var direction_count: int = 4
## Tamaño de cada celda de las tiras de animación.
@export var frame_size: Vector2i = Vector2i(64, 64)
## Carpeta con los PNG: player_<animación>_<dirección>.png (una tira horizontal de frames).
@export_dir var sprites_path: String = "res://Assets/art/sprites/player"
## Animaciones que se buscan y sus cuadros por segundo. Sumar una acá y soltar el PNG alcanza.
@export var animations: Dictionary = {
	"idle": 4.0,
	"walk": 8.0,
	"sit": 4.0,
	"sleep": 2.0,
	"use_computer": 4.0,
}
