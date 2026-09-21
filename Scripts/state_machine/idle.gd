extends PlayerState
## Parado, sin hacer nada.


func enter(_msg: Dictionary = {}) -> void:
	player.velocity = Vector2.ZERO
	player.play_animation(&"idle")
