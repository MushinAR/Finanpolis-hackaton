class_name StatSet
extends Resource
## La lista de variables que tiene el jugador. Vive en Data/stats/stat_set.tres.
## El orden de la lista es el orden en que aparecen en el HUD.

@export var stats: Array[StatData] = []


func find(id: StringName) -> StatData:
	for data in stats:
		if data and data.id == id:
			return data
	return null
