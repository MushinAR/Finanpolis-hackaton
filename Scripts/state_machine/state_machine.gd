class_name StateMachine
extends Node
## Máquina de estados genérica. Maneja los estados (nodos hijos) de su dueño.

## Se emite después de cada cambio de estado (nombre en minúsculas).
signal state_changed(state_name: StringName)

## Estado con el que arranca (en minúsculas).
@export var initial_state: StringName = &"idle"

var current_state: State
var states: Dictionary[StringName, State] = {}


func _ready() -> void:
	for child in get_children():
		if child is State:
			states[StringName(child.name.to_lower())] = child
			child.state_machine = self
	# Los hijos hacen _ready antes que el dueño: esperamos al Player para que su sprite ya exista.
	if owner and not owner.is_node_ready():
		await owner.ready
	if states.has(initial_state):
		switch_state(initial_state)
	else:
		push_error("StateMachine: no existe el estado inicial '%s'" % initial_state)


func _physics_process(delta: float) -> void:
	if current_state:
		current_state.physics_update(delta)


## Cambia de estado. `msg` le llega tal cual al enter() del nuevo.
func switch_state(new_state_name: StringName, msg: Dictionary = {}) -> void:
	var key := StringName(String(new_state_name).to_lower())
	if not states.has(key):
		push_error("StateMachine: no existe el estado '%s'" % new_state_name)
		return
	if current_state:
		current_state.exit()
	current_state = states[key]
	current_state.enter(msg)
	state_changed.emit(key)
