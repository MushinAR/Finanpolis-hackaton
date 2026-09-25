class_name State
extends Node
## Base de todos los estados (del Player, de la compu, de la lámpara...).
## Cada estado hereda de acá (o de una base más específica, como PlayerState) y pisa lo que necesite.

## Se la asigna la StateMachine al arrancar.
var state_machine: StateMachine


## Al entrar al estado. `msg` trae datos del estado anterior (destino, objeto, etc.).
func enter(_msg: Dictionary = {}) -> void:
	pass


## Al salir del estado. Acá se limpia lo que haya quedado a medias.
func exit() -> void:
	pass


## Cada frame de física mientras el estado está activo.
func physics_update(_delta: float) -> void:
	pass
