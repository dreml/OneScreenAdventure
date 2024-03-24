class_name Player
extends CharacterBody2D

enum States { IDLE, FOLLOW, ATTACK }

const MASS: float = 1.0
const ARRIVE_DISTANCE: float = 5.0
const AT_CONDITION_PATH: String = "parameters/StateMachine/conditions/%s"
const AT_BLEND_POSITION_PATH: String = "parameters/StateMachine/%s/blend_position"

@export var speed: float = 200.0
@export var nav_path: NodePath
@export var pointer_path: NodePath

@onready var animation_tree: AnimationTree = $AnimationTree
@onready var nav: NavigationMap = get_node(nav_path)
@onready var pointer: Node2D = get_node(pointer_path)

var _state := States.IDLE

var _path = []
var _target_point_world: Vector2 = Vector2()
var _target_position: Vector2 = Vector2()
var _facing_direction: Vector2 = Vector2()
var _velocity: Vector2 = Vector2()
var _target_building: Building

var _animation_name_by_state = {
	States.IDLE: "Idle",
	States.FOLLOW: "Running",
	States.ATTACK: "Attacking",
}

# ресурсы
var gold_ore_amount = 0
var wood_amount = 0

func _ready():
	_change_state(States.IDLE)

func _process(_delta) -> void:
	_update_animation_direction()

	if _state != States.FOLLOW:
		return

	_facing_direction = global_position.direction_to(_target_point_world).normalized()

	var _arrived_to_next_point: bool = _move_to(_target_point_world)
	if _arrived_to_next_point:
		_path.remove_at(0)
		if len(_path) == 0:
			_change_state(States.IDLE)
			return
		_target_point_world = _path[0]
	
func _unhandled_input(event) -> void:
	if Input.is_key_pressed(KEY_F):
		_change_state(States.ATTACK)
		return
	
	if event.is_action_pressed("click"):
		_start_following()

func _start_following():
	_target_building = _get_target_building()
	
	var destination: Vector2
	
	if is_instance_valid(_target_building):
		destination = _get_target_building_entrance_point()
	else:
		destination = get_global_mouse_position()

	if Input.is_key_pressed(KEY_SHIFT):
		global_position = destination
	else:
		_target_position = destination

	_change_state(States.FOLLOW)
	
func _get_target_building_entrance_point():
	var rect = _target_building.get_rect_global()
	
	return _target_building.global_position + Vector2(0, rect.size.y * 2)

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
		_path = nav.get_astar_path(position, _target_position)
		if not _path or len(_path) == 1:
			_change_state(States.IDLE)
			return
		_target_point_world = _path[1]

		if is_instance_valid(_target_building):
			var rect = _target_building.get_rect_global()
			
			pointer.wrap_around(rect)
			pointer.position = rect.position
		else:
			pointer.position = _path.back()
	elif new_state == States.IDLE:
		pointer.position = Vector2(-100, -100)
		pointer.reset()
		_target_building = null

	_state = new_state
	_switch_animation()

func _switch_animation():
	for state in States:
		var animation_name = _animation_name_by_state[States[state]]
		animation_tree[AT_CONDITION_PATH % animation_name] = States[state] == _state

func _update_animation_direction():
	var animation_name = _animation_name_by_state[_state]
	var blend_position = _facing_direction

	if _state != States.ATTACK:
		blend_position = blend_position.x

	animation_tree[AT_BLEND_POSITION_PATH % animation_name] = blend_position

func attack():
	print("Attacking")
	_change_state(States.IDLE)
	
func get_resourse(type, amount):
	GameInstance.get_resource(type, amount)
