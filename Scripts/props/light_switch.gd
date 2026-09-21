class_name LightSwitch
extends TogglableProp
## Interruptor de la pared: prende y apaga la luz del techo.

@export var target: CeilingLight


func _ready() -> void:
	# Arranca en el mismo estado que la luz que controla.
	if target:
		starts_on = target.starts_lit
	super()


func apply_state(is_on: bool) -> void:
	super(is_on)
	# Al arrancar la luz todavía puede no estar lista; ya empieza en el mismo estado (starts_lit).
	if target and target.is_node_ready():
		target.set_lit(is_on)
