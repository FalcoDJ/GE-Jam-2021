extends Control



func _on_Button_pressed() -> void:
	SceneChanger.change_scene("res://src/World.tscn", 0.05)
