class_name Goblin
extends Npc

var hp = 50

#func _ready() -> void:
#	super._ready()

func _unhandled_input(event: InputEvent) -> void:
	if Input.is_key_pressed(KEY_A) and name == 'Goblin':
		move_to(get_global_mouse_position())
		
func move_to(location: Vector2):
	movement_component.set_target_position(location)
	_switch_state(States.FOLLOW)

func take_damage(damage):
	hp -= damage
	if hp <= 0:
		queue_free()

