class_name MovementComponent
extends Component

signal arrived
signal facing_direction_changed

const MASS: float = 10.0
const ARRIVE_DISTANCE: float = 5.0

@export var speed: float = 200.0

@onready var nav: NavigationMap = get_tree().get_root().get_node('Main/NavigationMap')

var _path = []
var _target_point_world: Vector2 = Vector2()
var _velocity: Vector2 = Vector2()
var facing_direction := Vector2(1.0, 0.0):
	set(new_value):
		facing_direction = new_value
		facing_direction_changed.emit()
var can_move := false

func _process(_delta) -> void:
	if not can_move:
		return
		
	facing_direction = owner.global_position.direction_to(_target_point_world)

	var _arrived_to_next_point: bool = _move_to(_target_point_world)
	if _arrived_to_next_point:
		_path.remove_at(0)
		if len(_path) == 0:
			arrived.emit()
			return
		_target_point_world = _path[0]

func _move_to(world_position) -> bool:
	var desired_velocity = (world_position - owner.position).normalized() * speed
	var steering = desired_velocity - _velocity
	_velocity += steering / MASS
	owner.translate(_velocity * get_process_delta_time())
	return owner.position.distance_to(world_position) < ARRIVE_DISTANCE

func set_target_position(target_position: Vector2):
	_path = nav.get_astar_path(owner.position, target_position)
	_target_point_world = _path[1]
	if not _path or len(_path) == 1:
		arrived.emit()

func stop():
	_target_point_world = position
	_path = []

