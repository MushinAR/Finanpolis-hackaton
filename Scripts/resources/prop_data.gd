class_name PropData
extends Resource
## Datos de cómo se usa un Prop (cama, silla, compu...). Los valores viven en Data/props/*.tres,
## así se cambian desde el inspector sin tocar código.

@export var display_name: String = "Prop"
## Animación del Player mientras lo usa (sit, sleep, use_computer...).
@export var animation: StringName = &"idle"
## Para dónde mira el Player mientras lo usa (se, sw, nw, ne).
@export var facing: StringName = &"se"
## Cuánto dura en segundos. 0 = hasta que el jugador haga otra cosa (dormir, sentarse).
@export_range(0.0, 600.0, 0.5, "suffix:s") var duration: float = 0.0
## Si es true, el prop se queda con el item que el jugador lleve (ej: el basurero).
@export var accepts_items: bool = false

@export_group("Efectos")
## Lo que le cambia al jugador por usarlo hasta el final: { "energia": 40.0, "estres": -10.0 }.
## Con duration 0 nunca se cobra: esos props usan effects_per_second.
@export var effects_on_finish: Dictionary = {}
## Lo que le cambia al jugador por cada segundo que lo usa. Para la cama, la silla y
## todo lo que dura "hasta que el jugador haga otra cosa".
@export var effects_per_second: Dictionary = {}
