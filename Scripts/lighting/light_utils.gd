class_name LightUtils
extends RefCounted
## Cosas comunes para prender y apagar luces con un fundido suave.


## Lleva la luz a `energy` en `time` segundos. Si termina en 0, la deja deshabilitada.
static func fade(light: PointLight2D, energy: float, time: float = 0.25) -> void:
	if light.has_meta(&"fade_tween"):
		var old: Tween = light.get_meta(&"fade_tween")
		if old and old.is_valid():
			old.kill()
	light.enabled = true
	var tween := light.create_tween()
	light.set_meta(&"fade_tween", tween)
	tween.tween_property(light, "energy", energy, time)
	if energy <= 0.0:
		tween.tween_callback(func(): light.enabled = false)
