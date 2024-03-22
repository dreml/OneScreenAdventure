class_name Player
extends CharacterBody2D

enum States { 
	IDLE,
	FOLLOW, 
}

signal dead
signal health_changed

const MASS: float = 1.0
const ARRIVE_DISTANCE: float = 5.0
const AT_CONDITION_PATH: String = "parameters/StateMachine/conditions/%s"
const AT_BLEND_POSITION_PATH: String = "parameters/StateMachine/%s/blend_position"
const AT_ATTACK_PATH: String = "parameters/Attack/request"

@export var speed: float = 200.0
@export var nav_path: NodePath
@export var pointer_path: NodePath
@export var attack_cd: int = 1 
@export var attack_damage: int = 1

@onready var animation_tree: AnimationTree = $AnimationTree
@onready var nav: NavigationMap = get_node(nav_path)
@onready var pointer: Node2D = get_node(pointer_path)
@onready var attack_cd_timer: Timer = $AttackCDTimer
@onready var health_component: HealthComponent = $HealthComponent

var _state := States.IDLE

var _path = []
var _target_point_world: Vector2 = Vector2()
var _target_position: Vector2 = Vector2()
var _facing_direction: Vector2 = Vector2()
var _velocity: Vector2 = Vector2()
var _attack_target: Node2D: 
	set(new_target):
		if new_target == null and _attack_target:
			_attack_target.cancel_attack()
		_attack_target = new_target

var _animation_name_by_state = {
	States.IDLE: "Idle",
	States.FOLLOW: "Running",
}

# ресурсы
var gold_ore_amount = 0
var wood_amount = 0

func _ready():
	_change_state(States.IDLE)
	attack_cd_timer.set_wait_time(attack_cd)
	attack_cd_timer.timeout.connect(_make_attack)
	health_component.health_changed.connect(func(): health_changed.emit())
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
			_change_state(States.IDLE)
			return
		
		_target_point_world = _path[0]
	
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("click"):
		var global_mouse_pos: Vector2 = get_global_mouse_position()
		_target_position = global_mouse_pos
		_change_state(States.FOLLOW)
		
func _move_to(world_position) -> bool:
	var desired_velocity = (world_position - position).normalized() * speed
	var steering = desired_velocity - _velocity
	_velocity += steering / MASS
	position += _velocity * get_process_delta_time()
	return position.distance_to(world_position) < ARRIVE_DISTANCE

func _change_state(new_state) -> void:
	if new_state == States.FOLLOW:
		_attack_target = null
		attack_cd_timer.stop()
		animation_tree[AT_ATTACK_PATH] = AnimationNodeOneShot.ONE_SHOT_REQUEST_ABORT

		_path = nav.get_astar_path(position, _target_position)
		if not _path or len(_path) == 1:
			_change_state(States.IDLE)
			return
		_target_point_world = _path[1]
		pointer.position = _path.back()
	elif new_state == States.IDLE:
		pointer.position = Vector2(-100, -100)

	_state = new_state
	_switch_animation()

func _switch_animation():
	for state in States:
		var animation_name = _animation_name_by_state[States[state]]
		animation_tree[AT_CONDITION_PATH % animation_name] = States[state] == _state

func _update_animation_direction():
	if _state != States.FOLLOW:
		return

	var animation_name = _animation_name_by_state[_state]
	animation_tree[AT_BLEND_POSITION_PATH % animation_name] = _facing_direction.x

func get_resourse(type, amount):
	GameInstance.get_resource(type, amount)

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
		_attack_next_target()

func _make_attack():
	attack_cd_timer.start()
	animation_tree[AT_ATTACK_PATH] = AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE
	await get_tree().create_timer(0.3).timeout

	if _attack_target and _attack_target.has_method("take_damage"):
		_attack_target.take_damage(attack_damage)

func _can_attack_target(target: Node2D) -> bool:
	return target.is_in_group("goblins") and target.has_method("attacked") and not _attack_target

func _start_attack(target: Node2D):
	attack_cd_timer.start()
	_attack_target = target
	_attack_target.dead.connect(_attack_target_dead)
	_attack_target.attacked()

func _attack_target_dead():
	attack_cd_timer.stop()
	_attack_next_target()

func _attack_next_target():
	var next_enemy := _get_enemy_in_range()
	_attack_target = null
	if next_enemy:
		_start_attack(next_enemy)
	else:
		_change_state(States.IDLE)

func _get_enemy_in_range() -> Node2D:
	var enemies: Array[Node2D] = $DetectEnemyArea.get_overlapping_bodies()
	for enemy in enemies:
		if enemy == _attack_target or not _can_attack_target(enemy):
			return
		
		return enemy

	return null

func _stop_attack():
	attack_cd_timer.stop()
	_attack_target = null
#endregion
