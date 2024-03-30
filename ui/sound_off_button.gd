extends Node

var _sound = AudioServer.get_bus_index("Master")
	
func _on_texture_button_pressed():
	AudioServer.set_bus_mute(_sound, not AudioServer.is_bus_mute(_sound))
