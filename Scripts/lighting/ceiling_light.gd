class_name CeilingLight
extends Node2D
## Luz principal del techo: ilumina toda la habitación. La controla el LightSwitch.

## Avisa cuando se prende o se apaga.
signal lit_changed(is_lit: bool)

## Intensidad con la luz prendida.
@export var energy_on: float = 1.1
## Dibujo de la lámpara colgando, apagada y prendida.
@export var texture_off: Texture2D
@export var texture_on: Texture2D
## Si arranca prendida.
@export var starts_lit: bool = true

var is_lit: bool = false

@onready var light: PointLight2D = $Light
@onready var sprite: Sprite2D = $Sprite


func _ready() -> void:
	is_lit = starts_lit
	light.energy = energy_on if is_lit else 0.0
	light.enabled = is_lit
	_update_sprite()


func set_lit(lit: bool) -> void:
	if lit == is_lit:
		return
	is_lit = lit
	LightUtils.fade(light, energy_on if lit else 0.0, 0.3)
	_update_sprite()
	lit_changed.emit(lit)


func _update_sprite() -> void:
	sprite.texture = texture_on if is_lit else texture_off
