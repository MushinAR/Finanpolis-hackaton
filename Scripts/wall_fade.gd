class_name WallFade
extends TileMapLayer
## Va sobre la capa de paredes. Le pasa al shader dónde está el jugador para que
## las paredes que lo tapan se pongan translúcidas.

## Grupo donde buscar a quién seguir. El Player está en el grupo "player".
@export var target_group: StringName = &"player"

var _target: Node2D
var _mat: ShaderMaterial


func _ready() -> void:
	_mat = material as ShaderMaterial
	if _mat == null:
		push_warning("WallFade: la capa no tiene un ShaderMaterial con wall_fade.gdshader")
		set_process(false)


func _process(_delta: float) -> void:
	if _target == null or not is_instance_valid(_target):
		_target = get_tree().get_first_node_in_group(target_group) as Node2D
		if _target == null:
			return
	# El shader trabaja en coordenadas del mundo, igual que el vertex().
	_mat.set_shader_parameter(&"target", _target.global_position)
