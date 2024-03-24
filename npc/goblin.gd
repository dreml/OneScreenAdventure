class_name Goblin
extends Npc

#func _ready() -> void:
#	super._ready()

func _unhandled_input(event: InputEvent) -> void:
	if Input.is_key_pressed(KEY_A) and name == 'Goblin':
		move_to(get_global_mouse_position())
		
func move_to(location: Vector2):
	movement_component.set_target_position(location)
	_switch_state(States.FOLLOW)
