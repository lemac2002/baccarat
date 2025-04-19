extends Control

func _on_play_pressed() -> void:
	print("Play Pressed")
	var sfx = AudioStreamPlayer.new()
	sfx.stream = preload("res://assets/Sounds/Minimalist1.mp3")
	add_child(sfx)
	sfx.play()
	get_tree().change_scene_to_file("res://scenes/Game.tscn")

func _on_instructions_pressed() -> void:
	print("Instructions Pressed")
	var sfx = AudioStreamPlayer.new()
	sfx.stream = preload("res://assets/Sounds/Minimalist2.mp3")
	add_child(sfx)
	sfx.play()
	get_tree().change_scene_to_file("res://scenes/instructions.tscn")

func _on_exit_pressed() -> void:
	get_tree().quit()
