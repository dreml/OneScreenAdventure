class_name Npc
extends Character

signal dead

# такие числа, чтобы потомки легко могли задавать свои состояния
enum States { IDLE = 100, FOLLOW = 101, ATTACK = 102 }

var ANIMATIONS_BY_STATES: Dictionary = {
	States.IDLE: 'idle',
	States.FOLLOW: 'run',
	States.ATTACK: 'idle',
}

@onready var character_animation: CharacterAnimationComponent = $CharacterAnimationComponent
@onready var death_sound: AudioStreamPlayer2D = $DeathSound

func _ready() -> void:
	state = States.IDLE
	
	character_animation.set_animations(ANIMATIONS_BY_STATES)
	character_animation.switch_animation()
	
	movement_component.arrived.connect(_change_state.bind(States.IDLE))
	movement_component.facing_direction_changed.connect(character_animation.update_animation_direction)
	health_component.dead.connect(
		func():
			dead.emit()
			death_sound.play()
			await death_sound.finished
			queue_free()
	)

func _change_state(new_state):
	if state == new_state:
		return
	
	state = new_state

	movement_component.can_move = state == States.FOLLOW

func take_damage(damage_amount: int):
	health_component.take_damage(damage_amount)
	
func is_idle():
	return state == States.IDLE
