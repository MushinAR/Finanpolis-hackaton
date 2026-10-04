class_name Palette
extends RefCounted
## Paleta semántica de Finanpolis. Sale de Docs/Finanpolis_UI_Guidelines.pdf.
## Ningún color de interfaz se escribe fuera de acá, y ninguno se usa fuera de su categoría:
## el rojo nunca es decorativo ni indica selección.

## Estabilidad, dinero positivo, crecimiento. Solo estados positivos de la economía.
const VERDE_ESTABILIDAD := Color("4caf6d")
## Banco, calma, información. Solo elementos de sistema / info neutra (y la selección).
const AZUL_INFO := Color("3b82c4")
## Oportunidad, aviso, energía. Solo alertas leves o eventos de oportunidad.
const AMARILLO_AVISO := Color("e8b84b")
## Deuda, riesgo, urgencia. Nunca decorativo, solo peligro real.
const ROJO_RIESGO := Color("d9534f")
## Cansancio, rutina, crisis. Solo estados negativos no urgentes.
const GRIS_NEUTRO := Color("8a8a8a")
## Hogar, calidez, vida cotidiana. Solo contexto doméstico / personal.
const NARANJA_HOGAR := Color("e58a4e")
## Texto principal.
const TEXTO_OSCURO := Color("1e1e1e")
## Fondo base del HUD y de los paneles.
const FONDO_CALIDO := Color("f7f5f2")

## Arriba de esto la barra va en verde.
const BAR_GOOD: float = 0.6
## Entre este valor y BAR_GOOD va en amarillo; abajo, en rojo.
const BAR_WARN: float = 0.3


## Color dinámico de una barra de bienestar, según qué tan llena está.
## `inverted` da vuelta la escala para el estrés: bajo = verde, alto = rojo.
static func bar_color(ratio: float, inverted: bool = false) -> Color:
	var level := 1.0 - ratio if inverted else ratio
	if level > BAR_GOOD:
		return VERDE_ESTABILIDAD
	if level >= BAR_WARN:
		return AMARILLO_AVISO
	return ROJO_RIESGO
