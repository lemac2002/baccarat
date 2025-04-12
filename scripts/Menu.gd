extends Control

func _on_play_pressed() -> void:
	print("Play Pressed")
	get_tree().change_scene_to_file("res://scenes/Game.tscn")

func _on_instructions_pressed() -> void:
	print("Instructions Pressed")
	get_tree().change_scene_to_file("res://scenes/Instructions.tscn")

func _on_exit_pressed() -> void:
	get_tree().quit()
