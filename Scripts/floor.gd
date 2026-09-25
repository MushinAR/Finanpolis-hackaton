class_name Floor
extends Node2D
## El piso del nivel: dos capas de TileMap (Ground = piso, Walls = paredes con colisión).
## Se pinta desde el editor. La navegación sale de acá: todo el Ground es caminable
## y lo que tenga colisión (Walls) lo bloquea.

@onready var ground: TileMapLayer = $Ground
@onready var walls: TileMapLayer = $Walls


## Borde del área caminable (en coordenadas globales): el rombo que rodea todo el Ground pintado.
func get_walkable_outline() -> PackedVector2Array:
	var rect := ground.get_used_rect()
	var half := Vector2(ground.tile_set.tile_size) / 2.0
	var last := rect.end - Vector2i.ONE
	return PackedVector2Array([
		ground.to_global(ground.map_to_local(rect.position)) + Vector2(0, -half.y),
		ground.to_global(ground.map_to_local(Vector2i(last.x, rect.position.y))) + Vector2(half.x, 0),
		ground.to_global(ground.map_to_local(last)) + Vector2(0, half.y),
		ground.to_global(ground.map_to_local(Vector2i(rect.position.x, last.y))) + Vector2(-half.x, 0),
	])
