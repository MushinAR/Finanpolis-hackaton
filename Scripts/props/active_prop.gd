class_name ActiveProp
extends Prop
## Prop que se ve distinto mientras lo usan (heladera abierta, horno prendido, tele prendida).
## Las dos imágenes tienen que medir lo mismo, así no se mueve nada al cambiar.

@export var texture_idle: Texture2D
@export var texture_active: Texture2D


func _ready() -> void:
	super()
	interaction_started.connect(_on_started)
	interaction_finished.connect(_on_finished)


func _on_started(_player: Player) -> void:
	sprite.texture = texture_active


func _on_finished(_player: Player, _completed: bool) -> void:
	sprite.texture = texture_idle
