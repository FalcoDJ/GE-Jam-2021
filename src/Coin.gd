extends Area2D

onready var anim_player = $AnimationPlayer

func _ready() -> void:
	var frame : float = rand_range(0, anim_player.get_animation("Spin").length)
	anim_player.play("Spin")
	anim_player.seek(frame, true)
