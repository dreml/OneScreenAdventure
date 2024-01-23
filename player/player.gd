extends CharacterBody2D

enum States { IDLE, FOLLOW, ATTACK }

const MASS: float = 10.0
const ARRIVE_DISTANCE: float = 5.0

@export var speed: float = 200.0
@export var nav_path: NodePath
@export var pointer_path: NodePath

@onready var animation_tree: AnimationTree = $AnimationTree
@onready var nav: Pathfinding = get_node(nav_path)
@onready var pointer: Node2D = get_node(pointer_path)

var _state: int = States.IDLE

var _path = []
var _target_point_world: Vector2 = Vector2()
var _target_position: Vector2 = Vector2()
var _facing_direction: Vector2 = Vector2()
var _velocity: Vector2 = Vector2():
	set(new_value):
		_facing_direction = new_value.snapped(Vector2.ONE)
		_velocity = new_value
		
		var diff = _target_point_world.x - position.x
		# TODO надо найти способ избавиться от лишних разворотов по оси X
		if diff > -5 and diff < 5:
			_facing_direction.x = 0

func _ready():
	_change_state(States.IDLE)

func _process(_delta) -> void:
	update_animation_direction()

	if _state != States.FOLLOW:
		return

	var _arrived_to_next_point: bool = _move_to(_target_point_world)
	if _arrived_to_next_point:
		_path.remove_at(0)
		if len(_path) == 0:
			_change_state(States.IDLE)
			return
		_target_point_world = _path[0]
	
func _unhandled_input(event):
	if Input.is_key_pressed(KEY_F):
		_change_state(States.ATTACK)
		return
	
	if event.is_action_pressed("click"):
		var global_mouse_pos: Vector2 = get_global_mouse_position()
		if Input.is_key_pressed(KEY_SHIFT):
			global_position = global_mouse_pos
		else:
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
		_path = nav.get_astar_path(position, _target_position)
		if not _path or len(_path) == 1:
			_change_state(States.IDLE)
			return
		_target_point_world = _path[1]
	elif new_state == States.IDLE:
		pointer.position = Vector2(-100, -100)

	_state = new_state
	switch_animation()

func _get_animation_name_by_state(state):
	match state:
		States.ATTACK:
			return "Attacking"
		States.FOLLOW:
			return "Running"
		_:
			return "Idle"

func attack():
	print("Attacking")
	_change_state(States.IDLE)

func switch_animation():
	for state in States:
		var animation_name = _get_animation_name_by_state(States[state])
		animation_tree["parameters/StateMachine/conditions/" + animation_name] = States[state] == _state

func update_animation_direction():
	var animation_name = _get_animation_name_by_state(_state)
	var blend_position
	
	match _state:
		States.ATTACK:
			blend_position = _facing_direction
		_:
			blend_position = sign(_facing_direction.x)

	animation_tree["parameters/StateMachine/" + animation_name + "/blend_position"] = blend_position
