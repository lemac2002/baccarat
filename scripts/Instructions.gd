extends Control


func _on_back_pressed() -> void:
	print("Instructions Pressed")
	var sfx = AudioStreamPlayer.new()
	sfx.stream = preload("res://assets/Sounds/Minimalist2.mp3")
	add_child(sfx)
	sfx.play()
	get_tree().change_scene_to_file("res://scenes/Main.tscn")
