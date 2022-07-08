extends Node

const fade_in = preload("res://src/Transitions/FadeIn.tscn")
const slide_out = preload("res://src/Transitions/SlideOut.tscn")

signal started
signal finished

func change_scene(path: String, delay = 0.0) -> void:
	emit_signal("started")
	yield(get_tree().create_timer(delay), "timeout")
	var start = fade_in.instance()
	add_child(start)
	yield(start, "finished")
	get_tree().change_scene(path)
	start.queue_free()
	var stop = slide_out.instance()
	add_child(stop)
	yield(stop, "finished")
	stop.queue_free()
	emit_signal("finished")
