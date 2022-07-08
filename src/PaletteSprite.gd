extends Sprite

export(Array, StreamTexture) var Palettes = null
export var Snail_Color : int = 0

func _ready() -> void:
	call_deferred("set_palette")

func set_palette():
	get_material().set_shader_param("palette", Palettes[Snail_Color])
