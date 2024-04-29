class_name Goblin
extends Npc

@export var attack_cd: int = 1 
@export var attack_damage: int = 1

@onready var attack_cd_timer: Timer = $AttackCDTimer

@export var home_camp: Camp

func _unhandled_input(_event: InputEvent) -> void:
	if Input.is_key_pressed(KEY_A) and name == 'Goblin':
		move_to(get_global_mouse_position())
		
func _ready():
	super._ready()

	attack_cd_timer.set_wait_time(attack_cd)
	attack_cd_timer.timeout.connect(_make_attack)

	health_component.dead.connect(func(): home_camp.goblin_dead.emit())

func _change_state(new_state: States):
	var prev_state := _state
	
	super._change_state(new_state)

	if prev_state == States.ATTACK:
		attack_cd_timer.stop()

	if _state == States.ATTACK:
		attack_cd_timer.start()
		if prev_state == States.FOLLOW:
			movement_component.stop()

func move_to(location: Vector2):
	movement_component.set_target_position(location)
	_change_state(States.FOLLOW)

func attacked():
	_change_state(States.ATTACK)

func cancel_attack():
	_change_state(States.IDLE)

func _make_attack():
	animation_player.play("attack")
	await animation_player.animation_finished

	GameInstance.player.take_damage(attack_damage)
	animation_player.play("idle")
	attack_cd_timer.start()

func steal_resource(target_building: ProductBuilding):
	move_to(target_building.get_entrance())

func get_resource(_type, _amount):
	move_to(home_camp.portal.global_position)
	await movement_component.arrived
	home_camp.handle_goblin_delivered_resources(self)
