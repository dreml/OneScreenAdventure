class_name Goblin
extends Npc

enum OwnStates { PREPARE_ATTACK }

const ATTACK_STATES = [OwnStates.PREPARE_ATTACK, States.ATTACK]

@export var attack_cd: int = 1 
@export var attack_damage: int = 1

@onready var attack_cd_timer: Timer = $AttackCDTimer

func _unhandled_input(_event: InputEvent) -> void:
	if Input.is_key_pressed(KEY_A) and name == 'Goblin':
		move_to(get_global_mouse_position())
		
func _ready():
	ANIMATIONS_BY_STATES = Helpers.merge([
		ANIMATIONS_BY_STATES,
		{
			States.ATTACK: "attack",
			OwnStates.PREPARE_ATTACK: "idle"
		}
	])
	
	super._ready()

	attack_cd_timer.set_wait_time(attack_cd)
	attack_cd_timer.timeout.connect(_make_attack)

func _change_state(new_state):
	super._change_state(new_state)

	if ATTACK_STATES.has(prev_state):
		attack_cd_timer.stop()

	if state == OwnStates.PREPARE_ATTACK:
		attack_cd_timer.start()
		if prev_state == States.FOLLOW:
			movement_component.stop()

func move_to(location: Vector2):
	movement_component.set_target_position(location)
	_change_state(States.FOLLOW)

func attacked():
	movement_component.facing_direction = GameInstance.player.position
	_change_state(OwnStates.PREPARE_ATTACK)

func cancel_attack():
	_change_state(States.IDLE)

func _make_attack():
	_change_state(States.ATTACK)
	await character_animation_component.animation_finished

	if state != States.ATTACK:
		return

	GameInstance.player.take_damage(attack_damage)
	_change_state(OwnStates.PREPARE_ATTACK)
	attack_cd_timer.start()
