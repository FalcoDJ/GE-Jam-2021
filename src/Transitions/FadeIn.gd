extends CanvasLayer

onready var animation_player = $AnimationPlayer

signal finished

func _on_AnimationPlayer_animation_finished(anim_name: String) -> void:
	emit_signal("finished")
