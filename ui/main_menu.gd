extends CanvasLayer

func _on_continue_pressed():
	get_tree().change_scene_to_file("res://scenes/main.tscn")


func _on_start_pressed():
	get_tree().change_scene_to_file("res://scenes/main.tscn")


func _on_settings_pressed():
	print("SETTINGS")


func _on_quit_pressed():
	get_tree().quit()
