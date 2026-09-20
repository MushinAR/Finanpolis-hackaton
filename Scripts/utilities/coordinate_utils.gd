class_name CoordinateUtils
extends RefCounted
## Cuentas para la vista isométrica (2:1).

## Alto/ancho del rombo del tile. En 2:1 el eje Y se ve a la mitad.
const ISO_RATIO: float = 0.5

## Direcciones de pantalla ordenadas por ángulo (0° = este, va en sentido horario).
const DIRECTIONS: Array[StringName] = [&"e", &"se", &"s", &"sw", &"w", &"nw", &"n", &"ne"]


## Velocidad en pantalla para ir hacia `direction`. Sin esto, ir en vertical
## parecería el doble de rápido que ir en horizontal.
static func iso_velocity(direction: Vector2, speed: float) -> Vector2:
	var ground := Vector2(direction.x, direction.y / ISO_RATIO).normalized()
	return Vector2(ground.x, ground.y * ISO_RATIO) * speed


## Devuelve "e", "se", "s"... según para dónde apunta `direction`.
## Sirve para elegir la animación de 8 direcciones (ej: walk_se).
static func direction_name(direction: Vector2) -> StringName:
	var index := int(roundf(direction.angle() / (PI / 4.0)))
	return DIRECTIONS[posmod(index, 8)]
