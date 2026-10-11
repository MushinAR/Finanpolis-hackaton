class_name WallFadeSprites
extends Node2D
## Como WallFade, pero para paredes hechas con Sprites sueltos (un Sprite por tramo).
## Le pasa dónde está el jugador a los materiales de todo lo que esté en el grupo "wall_fade"
## (cada lado de la pared, una puerta...) para que lo que lo tapa se ponga translúcido.

## Grupo donde buscar a quién seguir. El Player está en el grupo "player".
@export var target_group: StringName = &"player"

var _target: Node2D
var _mats: Array[ShaderMaterial] = []

func _ready() -> void:
	for node in get_tree().get_nodes_in_group(&"wall_fade"):
		var mat := (node as CanvasItem).material as ShaderMaterial
		if mat and not _mats.has(mat):
			_mats.append(mat)
	if _mats.is_empty():
		push_warning("WallFadeSprites: no hay nada en el grupo 'wall_fade' con wall_fade_sprite.gdshader")
		set_process(false)

func _process(_delta: float) -> void:
	if _target == null or not is_instance_valid(_target):
		_target = get_tree().get_first_node_in_group(target_group) as Node2D
		if _target == null:
			return
	for mat in _mats:
		mat.set_shader_parameter(&"target", _target.global_position)
