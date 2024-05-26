class_name NavigationMap
extends TileMap

@export var map_size: Vector2i = Vector2i.ONE * 16

@onready var astar_grid := AStarGrid2D.new()
var path_start_position: Vector2i = Vector2i(): set = _set_path_start_position
var path_end_position: Vector2i = Vector2i(): set = _set_path_end_position

var _point_path = []
var cell_size: int = 32

func build_bridge():
	astar_grid.set_point_solid(Vector2i(13, 30), false)
	astar_grid.set_point_solid(Vector2i(14, 30), false)
	astar_grid.set_point_solid(Vector2i(15, 30), false)
	astar_grid.set_point_solid(Vector2i(16, 30), false)
	astar_grid.set_point_solid(Vector2i(17, 30), false)
	astar_grid.set_point_solid(Vector2i(18, 30), false)
	astar_grid.set_point_solid(Vector2i(19, 30), false)

func _ready():
	astar_grid.region = Rect2i(0, 0, map_size.x, map_size.y)
	astar_grid.cell_size = Vector2(cell_size, cell_size)
	astar_grid.offset = Vector2(32, 32)
	astar_grid.diagonal_mode = AStarGrid2D.DIAGONAL_MODE_ONLY_IF_NO_OBSTACLES
	astar_grid.update()

	astar_grid.fill_solid_region(Rect2i(0, 0, map_size.x, map_size.y), true)

	for cell in get_used_cells(0):
		astar_grid.set_point_solid(cell, false)

	calculate_obstacles()

func calculate_obstacles() -> void:
	for obstacle : Node2D in get_tree().get_nodes_in_group('obstacles'):
		var collision: CollisionShape2D = obstacle.get_node('Collision')
		assert(collision, 'No collision in %s node' % obstacle.get_name())
		assert(collision.shape, 'No collision shape in %s node' % obstacle.get_name())

		var collision_start: Vector2i = local_to_map(to_local(collision.global_position + collision.shape.get_rect().position))
		var collision_end: Vector2i = local_to_map(to_local(collision.global_position + collision.shape.get_rect().end))

		for x in range(collision_start.x, collision_end.x + 1):
			for y in range(collision_start.y, collision_end.y + 1):
				astar_grid.set_point_solid(Vector2i(x, y), true)

func get_astar_path(world_start, world_end) -> Array[Vector2]:
	path_start_position = local_to_map(to_local(world_start))
	path_end_position = local_to_map(to_local(world_end))
	_recalculate_path()
	var path_world: Array[Vector2] = []
	for point in _point_path:
		path_world.append(point)

	return path_world

func _recalculate_path():
	_point_path = astar_grid.get_point_path(path_start_position, path_end_position)

func is_outside_map_bounds(point: Vector2i) -> bool:
	return point.x < 0 or point.y < 0 or point.x >= map_size.x or point.y >= map_size.y

func _set_path_start_position(value) -> void:
	if is_outside_map_bounds(value):
		return
	if astar_grid.is_point_solid(value):
		return

	path_start_position = value
	if path_end_position and path_end_position != path_start_position:
		_recalculate_path()

func _set_path_end_position(value) -> void:
	if is_outside_map_bounds(value):
		return
	if astar_grid.is_point_solid(value):
		return

	path_end_position = value
	if path_start_position != value:
		_recalculate_path()

