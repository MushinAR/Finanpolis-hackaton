class_name ActiveProp
extends Prop
## Prop que se ve distinto mientras lo usan (heladera abierta, horno prendido, tele prendida).
## Las dos imágenes tienen que medir lo mismo, así no se mueve nada al cambiar.

@export var texture_idle: Texture2D
@export var texture_active: Texture2D
## Opcional: una animación que se dibuja encima solo mientras lo usan (la pantalla de la tele).
@export var active_animation: AnimatedSprite2D


func _ready() -> void:
	super()
	interaction_started.connect(_on_started)
	interaction_finished.connect(_on_finished)


func _on_started(_player: Player) -> void:
	if texture_active:
		sprite.texture = texture_active
	if active_animation:
		active_animation.show()
		active_animation.play()


func _on_finished(_player: Player, _completed: bool) -> void:
	sprite.texture = texture_idle
	if active_animation:
		active_animation.stop()
		active_animation.hide()
