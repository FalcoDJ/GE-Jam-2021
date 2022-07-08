extends ParallaxBackground

export(float) var scroll_speed = 50.0

func _process(delta: float) -> void:
	scroll_offset.x += scroll_speed * delta
