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
