class_name MovementComponent
extends Node2D

signal arrived

const MASS: float = 10.0
const ARRIVE_DISTANCE: float = 5.0

@onready var owner_actor: Node2D = get_parent()

@export var speed: float = 200.0

var _path = []
var _target_point_world: Vector2 = Vector2()
var _velocity: Vector2 = Vector2()
var nav: Pathfinding
var can_move := false

func _ready():
	nav = get_tree().get_root().get_node('Main/TileMap')

func _process(_delta) -> void:
	if not can_move:
		return
		
	var _arrived_to_next_point: bool = _move_to(_target_point_world)
	if _arrived_to_next_point:
		_path.remove_at(0)
		if len(_path) == 0:
			arrived.emit()
			return
		_target_point_world = _path[0]

func _move_to(world_position) -> bool:
	var desired_velocity = (world_position - owner_actor.position).normalized() * speed
	var steering = desired_velocity - _velocity
	_velocity += steering / MASS
	owner_actor.translate(_velocity * get_process_delta_time())
	return owner_actor.position.distance_to(world_position) < ARRIVE_DISTANCE

func set_target_position(target_position: Vector2):
	_path = nav.get_astar_path(owner_actor.position, target_position)
	_target_point_world = _path[1]
	if not _path or len(_path) == 1:
		arrived.emit()
