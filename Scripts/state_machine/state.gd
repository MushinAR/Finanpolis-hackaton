class_name State
extends Node
## Base de todos los estados del Player. Cada estado hereda de acá y pisa lo que necesite.

## Se la asigna la StateMachine al arrancar.
var state_machine: StateMachine

## El Player dueño de la escena. Los estados lo usan para moverlo y animarlo.
@onready var player: Player = owner as Player


## Al entrar al estado. `msg` trae datos del estado anterior (destino, objeto, etc.).
func enter(_msg: Dictionary = {}) -> void:
	pass


## Al salir del estado. Acá se limpia lo que haya quedado a medias.
func exit() -> void:
	pass


## Cada frame de física mientras el estado está activo.
func physics_update(_delta: float) -> void:
	pass
