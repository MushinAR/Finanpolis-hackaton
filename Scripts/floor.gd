class_name Floor
extends Node2D
## El piso de una habitación. La navegación sale de acá.
## Hoy las habitaciones son un dibujo entero y dan su borde caminable con `walkable_outline`.
## También sirve para un piso de tiles (capas Ground y Walls): ahí el borde sale del Ground pintado.

## Para pisos que son un dibujo entero y no tiles (ej: la pieza): el borde caminable,
## en coordenadas locales. Si está vacío, sale del Ground.
@export var walkable_outline: PackedVector2Array

@onready var ground: TileMapLayer = get_node_or_null("Ground")
@onready var walls: TileMapLayer = get_node_or_null("Walls")


## Borde del área caminable (en coordenadas globales): el rombo que rodea todo el Ground pintado.
func get_walkable_outline() -> PackedVector2Array:
	if not walkable_outline.is_empty():
		return global_transform * walkable_outline
	var rect := ground.get_used_rect()
	var half := Vector2(ground.tile_set.tile_size) / 2.0
	var last := rect.end - Vector2i.ONE
	return PackedVector2Array([
		ground.to_global(ground.map_to_local(rect.position)) + Vector2(0, -half.y),
		ground.to_global(ground.map_to_local(Vector2i(last.x, rect.position.y))) + Vector2(half.x, 0),
		ground.to_global(ground.map_to_local(last)) + Vector2(0, half.y),
		ground.to_global(ground.map_to_local(Vector2i(rect.position.x, last.y))) + Vector2(-half.x, 0),
	])
