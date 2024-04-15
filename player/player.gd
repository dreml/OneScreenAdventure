class_name Player
extends CharacterBody2D

enum States { 
	IDLE,
	FOLLOW, 
}

signal dead
signal health_changed(current_health: int)

const MASS: float = 1.0
const ARRIVE_DISTANCE: float = 5.0
const AT_CONDITION_PATH: String = "parameters/StateMachine/conditions/%s"
const AT_BLEND_POSITION_PATH: String = "parameters/StateMachine/%s/blend_position"
const AT_ATTACK_BLEND_POSITION_PATH: String = "parameters/AttackBlendSpace/blend_position"
const AT_ATTACK_PATH: String = "parameters/Attack/request"

@export var speed: float = 200.0
@export var nav_path: NodePath
@export var pointer_path: NodePath
@export var attack_cd: int = 1 
@export var attack_damage: int = 1

@onready var animation_tree: AnimationTree = $AnimationTree
@onready var nav: NavigationMap = get_node(nav_path)
@onready var pointer: Pointer = get_node(pointer_path)
@onready var attack_cd_timer: Timer = $AttackCDTimer
@onready var health_component: HealthComponent = $HealthComponent

var _state := States.IDLE

var _path = []
var _target_point_world: Vector2 = Vector2()
var _target_position: Vector2 = Vector2()
var _facing_direction: Vector2 = Vector2()
var _velocity: Vector2 = Vector2()
var _target_building: Building
var _attack_target: Node2D: 
	set(new_target):
		if new_target == null and _attack_target:
			_attack_target.cancel_attack()
		_attack_target = new_target

var _animation_name_by_state = {
	States.IDLE: "Idle",
	States.FOLLOW: "Running",
}

func _ready():
	_change_state(States.IDLE)
	attack_cd_timer.set_wait_time(attack_cd)
	attack_cd_timer.timeout.connect(_play_attack_animation)
	health_component.health_changed.connect(func(current_health: int): health_changed.emit(current_health))
	health_component.dead.connect(func(): dead.emit())

func _process(_delta) -> void:
	_update_animation_direction()

	if _state != States.FOLLOW:
		return

	_facing_direction = global_position.direction_to(_target_point_world).normalized()

	var _arrived_to_next_point: bool = _move_to(_target_point_world)
	if _arrived_to_next_point:
		if len(_path) > 0:
			_path.remove_at(0)

		if len(_path) == 0:
			_reach_target()
			return
		
		_target_point_world = _path[0]
	
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("click"):
		_start_following()

func _start_following():
	_target_building = _get_target_building()

	if is_instance_valid(_target_building):
		_target_position = _target_building.get_entrance()
	else:
		_target_position = get_global_mouse_position()

	_change_state(States.FOLLOW)

func _get_target_building():
	var space_state = PhysicsServer2D.space_get_direct_state(get_world_2d().space)
	var query = PhysicsPointQueryParameters2D.new()
	query.position = get_global_mouse_position()
	var intersections = space_state.intersect_point(query, 1)
	
	for intersection in intersections:
		if intersection.collider.is_in_group("buildings"):
			return intersection.collider
		
	return null

func _move_to(world_position) -> bool:
	var desired_velocity = (world_position - position).normalized() * speed
	var steering = desired_velocity - _velocity
	_velocity += steering / MASS
	position += _velocity * get_process_delta_time()
	return position.distance_to(world_position) < ARRIVE_DISTANCE

func _change_state(new_state) -> void:
	if new_state == States.FOLLOW:
		_process_follow_state()
	elif new_state == States.IDLE:
		pointer.reset()
		if _get_enemy_in_range():
			_attack_next_target()

	_state = new_state
	_switch_animation()
	
func _process_follow_state():
	if _attack_target:
		_attack_target.dead.disconnect(_attack_target_dead)
		_attack_target = null
	attack_cd_timer.stop()
	animation_tree[AT_ATTACK_PATH] = AnimationNodeOneShot.ONE_SHOT_REQUEST_ABORT

	pointer.reset()

	_path = nav.get_astar_path(position, _target_position)
	if not _path or len(_path) == 1:
		_change_state(States.IDLE)
		return
	_target_point_world = _path[1]

	if is_instance_valid(_target_building):
		pointer.wrap_around(_target_building)
	else:
		pointer.set_position(_path.back())

func _switch_animation():
	for state in States:
		var animation_name = _animation_name_by_state[States[state]]
		animation_tree[AT_CONDITION_PATH % animation_name] = States[state] == _state

func _update_animation_direction():
	var animation_name = _animation_name_by_state[_state]
	animation_tree[AT_BLEND_POSITION_PATH % animation_name] = _facing_direction.x

func _reach_target():
	_change_state(States.IDLE)

	if _target_building != null && _target_building.start_building():
		GameInstance.game_director.create_order(
			Command.new(Command.ActionType.Build, _target_building)
		)

	_target_building = null

func get_resource(type, amount):
	GameInstance.get_resource(type, amount)

func get_resource_from_container(dict):
	GameInstance.get_resource_from_container(dict)

#region Атака
func take_damage(damage_amount: int):
	health_component.take_damage(damage_amount)

func _on_detect_enemy_area_body_entered(body: Node2D):
	if not _can_attack_target(body): 
		return

	_target_point_world = position
	_path = []

	_start_attack(body)

func _on_detect_enemy_area_body_exited(body):
	if not body.is_in_group("goblins"):
		return

	if body == _attack_target:
		_attack_target.dead.disconnect(_attack_target_dead)
		_attack_next_target()

func _play_attack_animation():
	var direction_to_enemy = position.direction_to(_attack_target.position).normalized()
	_facing_direction = Vector2(direction_to_enemy.x, -direction_to_enemy.y)
	animation_tree[AT_ATTACK_BLEND_POSITION_PATH] = _facing_direction
	animation_tree[AT_ATTACK_PATH] = AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE


func _make_attack():
	if _attack_target and _attack_target.has_method("take_damage"):
		_attack_target.take_damage(attack_damage)

func _can_attack_target(target: Node2D) -> bool:
	return not target.is_queued_for_deletion() and target.is_in_group("goblins") and target.has_method("attacked") 

func _start_attack(target: Node2D):
	if _attack_target and not _attack_target.is_queued_for_deletion():
		target.attacked()
		return

	attack_cd_timer.start()
	_attack_target = target
	_attack_target.dead.connect(_attack_target_dead)
	_attack_target.attacked()

func _attack_target_dead():
	attack_cd_timer.stop()
	_attack_next_target()

func _attack_next_target():
	_stop_attack()
	var next_enemy := _get_enemy_in_range()
	if next_enemy:
		_start_attack(next_enemy)
	else:
		_change_state(States.IDLE)

func _get_enemy_in_range() -> Node2D:
	var enemies: Array[Node2D] = $DetectEnemyArea.get_overlapping_bodies()
	for enemy in enemies:
		if not _can_attack_target(enemy):
			continue
		
		return enemy

	return null

func _stop_attack():
	if _attack_target and _attack_target.dead.is_connected(_attack_target_dead):
		_attack_target.dead.disconnect(_attack_target_dead)

	_attack_target = null
	attack_cd_timer.stop()
#endregion
	
