class_name Lamp
extends TogglableProp
## Lámpara de noche: al prenderla da un poco de luz cálida alrededor.

## Intensidad con la lámpara prendida (la del techo es bastante más fuerte).
@export var light_energy: float = 0.8

@onready var light: PointLight2D = $Light


func apply_state(is_on: bool) -> void:
	super(is_on)
	LightUtils.fade(light, light_energy if is_on else 0.0)
