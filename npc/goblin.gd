class_name Goblin
extends Npc

enum TargetActions {
	NO_ACTION,
	ATTACK_BUILDING,
	STEAL_RESOURCE,
	RETURN_TO_PORTAL
} 

enum OwnStates { PREPARE_ATTACK }

const ATTACK_STATES = [OwnStates.PREPARE_ATTACK, States.ATTACK]

@export var attack_cd: int = 1 
@export var attack_damage: int = 1
@export var time_between_actions: int = 2
@export var home_camp: Camp

@export_file var wood_drop: String
@export_file var meat_drop: String
@export_file var gold_drop: String

@onready var attack_cd_timer: Timer = $AttackCDTimer

var _target_action: TargetActions = TargetActions.NO_ACTION
var _target: Node2D
var _attack_target: Node2D
var _gathered_resources = []

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

	health_component.dead.connect(_handle_dead)

func _change_state(new_state):
	super._change_state(new_state)

	if ATTACK_STATES.has(prev_state):
		attack_cd_timer.stop()

	if state == OwnStates.PREPARE_ATTACK:
		attack_cd_timer.start()
		if prev_state == States.FOLLOW:
			movement_component.stop()

func _change_target_action(_ta: TargetActions, _tp: Node2D):
	_target_action = _ta
	_target = _tp
	_process_target_action()

func _process_target_action():
	if _target_action == TargetActions.NO_ACTION:
		return

	match _target_action:
		TargetActions.RETURN_TO_PORTAL:
			move_to(_target.global_position)
		TargetActions.ATTACK_BUILDING:
			_start_attack_building()
		TargetActions.STEAL_RESOURCE:
			move_to(_target.get_entrance())

func move_to(location: Vector2):
	movement_component.set_target_position(location)
	_change_state(States.FOLLOW)

func _handle_dead():
	home_camp.goblin_dead.emit()
	_drop_resources()

func _drop_resources():
	if _gathered_resources.is_empty():
		return
 
	var k := 0
	for resource in _gathered_resources:
		k += 1
		var drop = resource.instantiate() as ResourceDroppable
		drop.play("DROP")
		# Сдвиг ресурсов:
		# 1й: (0...23, 0...23)
		# 2й: (0...42, 0...23)
		# 3й: (0...61, 0...23)
		drop.global_position = position + Vector2(randi() % 5 + (k * randi() % 20), randi() % 5 + randi() % 20)
		GameInstance.main.call_deferred("add_child", drop)

func get_resource(_type, _amount):
	var drop_path
	match _type:
		Globals.ResourceType.WOOD:
			drop_path = wood_drop
		Globals.ResourceType.MEAT:
			drop_path = meat_drop
		Globals.ResourceType.GOLD_ORE:
			drop_path = gold_drop

	var resource = load(drop_path)
	for n in _amount:
		_gathered_resources.append(resource)	

	if _target_action == TargetActions.ATTACK_BUILDING:
		return

	_change_target_action(TargetActions.RETURN_TO_PORTAL, home_camp.portal)
	await movement_component.arrived
	home_camp.handle_goblin_delivered_resources(self)

#region Attack
func attacked():
	_attack_target = GameInstance.player
	movement_component.facing_direction = GameInstance.player.position
	_change_state(OwnStates.PREPARE_ATTACK)

func cancel_attack():
	_change_state(States.IDLE)
	await get_tree().create_timer(time_between_actions).timeout
	_process_target_action()

func _make_attack():
	if _attack_target == null or not _attack_target.has_method('take_damage'):
		return

	_change_state(States.ATTACK)
	await character_animation_component.animation_finished

	if state != States.ATTACK:
		return

	_attack_target.take_damage(attack_damage)
	_change_state(OwnStates.PREPARE_ATTACK)
	attack_cd_timer.start()

func steal_resource(target_building: ProductBuilding):
	_change_target_action(TargetActions.STEAL_RESOURCE, target_building)

func attack_building(target_building: Node2D):
	_change_target_action(TargetActions.ATTACK_BUILDING, target_building)

func _start_attack_building():
	_attack_target = _target
	_attack_target.dead.connect(_handle_attack_target_dead)

	move_to(_target.get_entrance())
	await movement_component.arrived
	_change_state(States.ATTACK)

func _handle_attack_target_dead():
	_attack_target = null
	_change_state(States.IDLE)
	await get_tree().create_timer(time_between_actions).timeout
	_change_target_action(TargetActions.RETURN_TO_PORTAL, home_camp.portal)
	await movement_component.arrived
	home_camp.handle_goblin_return_to_portal(self)
#endregion
