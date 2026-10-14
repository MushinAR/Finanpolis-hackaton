extends Node
class_name TimeManager

enum TimeSize { MINUTE, HOUR, DAY, WEEK, MONTH, YEAR }

signal time_passed(time_size: TimeSize)

# Cuántos segundos REALES (de reloj) dura un minuto completo dentro del juego.
@export var minute_duration_seconds: float = 1.0


# Las siguientes variables se basan en el tiempo VIRTUAL, es decir, el transcurrido dentro del juego.
const hours_per_day: int = 24
const days_per_week: int = 7
const week_per_month: int = 4
const months_per_year: int = 12

var time_multiplier: float = 1.0

var time: Dictionary = {
	TimeSize.MINUTE : 0,
	TimeSize.HOUR : 0,
	TimeSize.DAY : 0,
	TimeSize.WEEK : 0,
	TimeSize.MONTH: 0,
	TimeSize.YEAR : 0,
}

var _accumulated_seconds: float = 0.0

func _ready() -> void:
	set_time(TimeSize.HOUR, 12)
	set_time(TimeSize.MINUTE, 0)
	set_time(TimeSize.DAY, 1)
	set_time(TimeSize.WEEK, 1)
	set_time(TimeSize.MONTH, 1)
	set_time(TimeSize.YEAR, 2000)
	
func _process(delta: float) -> void:
	_accumulated_seconds += delta * time_multiplier

	while _accumulated_seconds >= minute_duration_seconds:
		_accumulated_seconds -= minute_duration_seconds
		_advance_minute()

func _advance_minute() -> void:
	time[TimeSize.MINUTE] += 1
	time_passed.emit(TimeSize.MINUTE)

	if time[TimeSize.MINUTE] >= 60:
		time[TimeSize.MINUTE] = 0
		_advance_hour()

func _advance_hour() -> void:
	time[TimeSize.HOUR] += 1
	time_passed.emit(TimeSize.HOUR)

	if time[TimeSize.HOUR] >= hours_per_day:
		time[TimeSize.HOUR] = 0
		_advance_day()

func _advance_day() -> void:
	time[TimeSize.DAY] += 1
	time_passed.emit(TimeSize.DAY)

	if time[TimeSize.DAY] >= days_per_week + 1:
		time[TimeSize.DAY] = 1
		_advance_week()
		
func _advance_week() -> void:
	time[TimeSize.WEEK] += 1
	time_passed.emit(TimeSize.WEEK)
	
	if time[TimeSize.WEEK] >= week_per_month + 1:
		time[TimeSize.WEEK] = 1
		_advance_year()
		
func _advance_month() -> void:
	time[TimeSize.MONTH] += 1
	time_passed.emit(TimeSize.MONTH)

	if time[TimeSize.MONTH] >= months_per_year + 1:
		time[TimeSize.MONTH] = 1
		_advance_year()

func _advance_year() -> void:
	time[TimeSize.YEAR] += 1
	time_passed.emit(TimeSize.YEAR)

func get_time(time_size: TimeSize) -> String:
	var value: int = time[time_size]
	match time_size:
		TimeSize.HOUR, TimeSize.MINUTE:
			return "%02d" % value
		_:
			return str(value)

func set_time(time_size : TimeSize, time_value : int):
	time[time_size] = time_value

func set_time_speed(scale : int):
	time_multiplier = scale
