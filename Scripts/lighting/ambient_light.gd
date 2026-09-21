class_name AmbientLight
extends CanvasModulate
## La luz de fondo de todo el escenario (en 2D esto hace de "environment").
## Cuanto más oscuro el color, menos se ve cuando no hay ninguna luz prendida.
## Más adelante se le puede cambiar el color según la hora del día (set_ambient).

## Color con todo apagado. Gris azulado oscuro: se ve "un poco", como de noche.
@export var dark_color: Color = Color(0.3, 0.32, 0.46)


func _ready() -> void:
	color = dark_color


## Cambia el color de fondo con un fundido (para el paso del día a la noche, etc.).
func set_ambient(new_color: Color, time: float = 1.0) -> void:
	create_tween().tween_property(self, "color", new_color, time)
