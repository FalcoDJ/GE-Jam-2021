extends Node

export(float,0.0,1.0) var RANGE = 0.5
export(float) var MULTIPLIER = 2.0
export(float,0.0,1.0) var THRESHOLD = 0.5

var acc_vec2d = Vector2.ZERO

signal tilt_detected_on_x_axis(acceleration)
signal tilt_detected_on_y_axis(acceleration)

func _process(delta: float) -> void:
	if abs(acc_vec2d.x) >= THRESHOLD:
		emit_signal("tilt_detected_on_x_axis", acc_vec2d.x)
	else:
		emit_signal("tilt_detected_on_x_axis", 0)
	
	if abs(acc_vec2d.y) >= THRESHOLD:
		emit_signal("tilt_detected_on_y_axis", acc_vec2d.y)
	else:
		emit_signal("tilt_detected_on_y_axis", 0)

func get_2d_acc() -> Vector2:
	return acc_vec2d

func _on_Timer_timeout() -> void:
	var acc = Input.get_accelerometer()
	acc_vec2d = Vector2(clamp(acc.x / 9.81, -RANGE, RANGE), clamp(-acc.y / 9.81, -RANGE, RANGE)) * MULTIPLIER
