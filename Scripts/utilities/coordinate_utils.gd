class_name CoordinateUtils
extends RefCounted
## Cuentas para la vista isométrica (2:1).

## Alto/ancho del rombo del tile. En 2:1 el eje Y se ve a la mitad.
const ISO_RATIO: float = 0.5

## Direcciones de pantalla ordenadas por ángulo (0° = este, va en sentido horario).
const DIRECTIONS_8: Array[StringName] = [&"e", &"se", &"s", &"sw", &"w", &"nw", &"n", &"ne"]
## Solo las diagonales, empezando por sudeste (45°). Coinciden con los bordes del piso isométrico.
const DIRECTIONS_4: Array[StringName] = [&"se", &"sw", &"nw", &"ne"]


## Velocidad en pantalla para ir hacia `direction`. Sin esto, ir en vertical
## parecería el doble de rápido que ir en horizontal.
static func iso_velocity(direction: Vector2, speed: float) -> Vector2:
	var ground := Vector2(direction.x, direction.y / ISO_RATIO).normalized()
	return Vector2(ground.x, ground.y * ISO_RATIO) * speed


## Devuelve el nombre de la dirección (ej: "se") según para dónde apunta `direction`.
## `count` es 4 u 8, según cuántas direcciones tenga el arte.
static func direction_name(direction: Vector2, count: int = 4) -> StringName:
	if count == 8:
		var index8 := roundi(direction.angle() / (PI / 4.0))
		return DIRECTIONS_8[posmod(index8, 8)]
	var index4 := roundi((direction.angle() - PI / 4.0) / (PI / 2.0))
	return DIRECTIONS_4[posmod(index4, 4)]


## Ángulo de pantalla (radianes) de una dirección por nombre. Útil para dibujar flechas o debug.
static func direction_angle(direction_name_: StringName) -> float:
	var index := DIRECTIONS_8.find(direction_name_)
	return index * PI / 4.0 if index >= 0 else PI / 2.0
