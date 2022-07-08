extends Node

signal swiped(direction, length_ratio)
signal swipe_canceled(direction)

export(float, 1.0, 1.5) var MAX_DIAGONAL_SLOPE = 1.3
export(float) var MAX_SWIPE_LENGTH = 200.0
export(float) var TIMER_TIME = 0.15

onready var timer = $Timer
var swipe_start_position = Vector2.ZERO

func _input(event: InputEvent) -> void:
	if not event is InputEventScreenTouch:
		return 
	if event.is_pressed():
		_start_detection(event.position)
	elif !timer.is_stopped():
		_end_detection(event.position)

func _start_detection(position: Vector2) -> void:
	swipe_start_position = position
	timer.start(TIMER_TIME)

func _end_detection(position: Vector2) -> void:
	timer.stop()
	var direction = (position - swipe_start_position).normalized()
	if abs(direction.x) + abs(direction.y) >= MAX_DIAGONAL_SLOPE:
		return
	
	var length = swipe_start_position.distance_to(position)
	if abs(direction.x) > abs(direction.y):
		emit_signal("swiped", Vector2(sign(direction.x), 0), clamp(1 - length/MAX_SWIPE_LENGTH, 0.0, 1.0))
	else:
		emit_signal("swiped", Vector2(0, sign(direction.y)), clamp(1 - length/MAX_SWIPE_LENGTH, 0.0, 1.0))

func _on_Timer_timeout() -> void:
	emit_signal("swipe_canceled", swipe_start_position)
