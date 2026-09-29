class_name StatData
extends Resource
## Definición de una variable del jugador (dinero, energía, felicidad, salud, estrés).
## Acá va solo el "cómo es" la variable; el valor vivo lo lleva un PlayerStat.
## Los valores se editan en Data/stats/*.tres, sin tocar código.
##
## Para sumar una variable nueva: crear el .tres, ponerle su ícono y agregarlo
## a Data/stats/stat_set.tres. El HUD la muestra sola.

## Nombre interno con el que la piden las otras escenas (ej: &"energia").
@export var id: StringName = &""
## Nombre que se ve en pantalla.
@export var display_name: String = ""
## Ícono del HUD (Assets/art/ui/icons/*.svg). El dibujo ya viene con su color.
@export var icon: Texture2D
## Color base del token en la paleta (ver Palette). Lo usan el dinero y los acentos.
## Las barras de bienestar NO lo usan: su color sale del valor (ver Palette.bar_color).
@export var color: Color = Color.WHITE

@export_group("Rango")
@export var min_value: float = 0.0
## Tope. Si es igual o menor al mínimo, la variable no tiene techo (el dinero).
@export var max_value: float = 100.0
@export var initial_value: float = 50.0

@export_group("Límites")
## Por debajo de este valor se avisa stat_reached_low (energía en rojo, plata que no alcanza).
@export var low_threshold: float = 20.0
## Por encima de este valor se avisa stat_reached_high (estrés por las nubes).
@export var high_threshold: float = 80.0
## True cuando tener mucho es malo (estrés): el HUD pinta de alerta la zona alta y no la baja.
@export var inverted: bool = false

@export_group("Desgaste")
## Cuánto cambia sola por cada minuto de juego. 0 = solo cambia por las acciones.
@export var change_per_minute: float = 0.0

@export_group("HUD")
## "bar" = ícono + barra. "number" = ícono + número (el dinero, que no tiene tope).
@export_enum("bar", "number") var display_mode: String = "bar"
## Se antepone al número (ej: "$").
@export var prefix: String = ""
## Separador de miles del número (ej: "46,426"). Vacío = sin separador.
@export var thousands_separator: String = ","


## False cuando la variable no tiene techo (dinero): no se puede dibujar como barra.
func has_max() -> bool:
	return max_value > min_value


func clamp_value(value: float) -> float:
	if has_max():
		return clampf(value, min_value, max_value)
	return maxf(value, min_value)


## 0.0 a 1.0 para la barra. Sin techo siempre devuelve 1.0.
func ratio(value: float) -> float:
	if not has_max():
		return 1.0
	return (value - min_value) / (max_value - min_value)


## Texto del número, con prefijo y separador de miles (ej: "$46,426").
func format_value(value: float) -> String:
	var digits := str(absi(roundi(value)))
	if not thousands_separator.is_empty():
		var grouped := ""
		for i in range(digits.length()):
			if i > 0 and (digits.length() - i) % 3 == 0:
				grouped += thousands_separator
			grouped += digits[i]
		digits = grouped
	return "%s%s%s" % ["-" if value < 0.0 else "", prefix, digits]
