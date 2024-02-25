class_name Pathfinding
extends TileMap

const BASE_LINE_WIDTH: float = 3.0
const DRAW_COLOR: Color = Color.WHITE

@export var map_size: Vector2 = Vector2.ONE * 16

@onready var astar_node: AStar2D = AStar2D.new()
# TODO разделить преграды на разные атласы и получать занятые клетки по id тайлсета
@onready var blocked_cells: Array[Vector2i] = get_used_cells(1) 

var path_start_position: Vector2i = Vector2i(): set = _set_path_start_position
var path_end_position: Vector2i = Vector2i(): set = _set_path_end_position

var _point_path = []
var cell_size: int = 64

func _ready():
	calculate_obstacles()
	var walkable_cells_list: Array[Vector2i] = astar_add_walkable_cells()
	astar_connect_walkable_cells_diagonal(walkable_cells_list)
	

#func _draw():
#	if not _point_path:
#		return
#
	# отрисовка пути
#	var point_start = _point_path[0]
#	var last_point = map_to_world(Vector2(point_start.x, point_start.y))
#	for index in range(1, len(_point_path)):
#		var current_point = map_to_world(Vector2(_point_path[index].x, _point_path[index].y))
#		draw_line(last_point, current_point, DRAW_COLOR, BASE_LINE_WIDTH, true)
#		draw_circle(current_point, BASE_LINE_WIDTH * 2.0, DRAW_COLOR)
#		last_point = current_point

func calculate_obstacles() -> void:
	for obstacle : Node2D in get_tree().get_nodes_in_group('obstacles'):
		var collision: CollisionShape2D = obstacle.get_node('Collision')
		assert(collision, 'No collision in %s node' % obstacle.get_name())
		assert(collision.shape, 'No collision shape in %s node' % obstacle.get_name())
		
		var collision_start: Vector2i = local_to_map(collision.global_position + collision.shape.get_rect().position) 
		var collision_end: Vector2i = local_to_map(collision.global_position + collision.shape.get_rect().end) 
		
		for x in range(collision_start.x, collision_end.x + 1):
			for y in range(collision_start.y, collision_end.y + 1):
				var obstacle_cell := Vector2i(x, y)
				if not obstacle_cell in blocked_cells:
					blocked_cells.append(obstacle_cell)

func astar_add_walkable_cells() -> Array[Vector2i]:
	var points_array: Array[Vector2i] = []
	for x in range(map_size.x):
		for y in range(map_size.y):
			var point: Vector2i = Vector2i(x, y)
			if point in blocked_cells:
				continue

			points_array.append(point)
			var point_index = calculate_point_index(point)
			astar_node.add_point(point_index, point)
			
	return points_array

func astar_connect_walkable_cells_diagonal(points_array):
	for point in points_array:
		var point_index = calculate_point_index(point)
		for local_x in range(3):
			for local_y in range(3):
				var point_relative: Vector2i = Vector2i(point.x + local_x - 1, point.y + local_y - 1)
				var point_relative_index = calculate_point_index(point_relative)
				if point_relative == point or is_outside_map_bounds(point_relative):
					continue
				if not astar_node.has_point(point_relative_index):
					continue
				astar_node.connect_points(point_index, point_relative_index, true)

func calculate_point_index(point):
	return point.x + map_size.x * point.y

#func clear_previous_path_drawing() -> void:
#	if not _point_path:
#		return
#	var point_start = _point_path[0]
#	var point_end = _point_path[len(_point_path) - 1]
	#set_cell(point_start.x, point_start.y, -1)
	#set_cell(point_end.x, point_end.y, -1)
	
	
func is_outside_map_bounds(point):
	return point.x < 0 or point.y < 0 or point.x >= map_size.x or point.y >= map_size.y
	
func get_astar_path(world_start, world_end) -> Array[Vector2]:
	path_start_position = local_to_map(world_start)
	path_end_position = local_to_map(world_end)
	_recalculate_path()
	var path_world: Array[Vector2] = []
	for point in _point_path:
		var point_world: Vector2 = map_to_local(Vector2(point.x, point.y)) 
		path_world.append(point_world)
		
	return path_world

func _recalculate_path():
#	clear_previous_path_drawing()
	var start_point_index = calculate_point_index(path_start_position)
	var end_point_index = calculate_point_index(path_end_position)
	_point_path = astar_node.get_point_path(start_point_index, end_point_index)
	#update()

func _set_path_start_position(value) -> void:
	if is_outside_map_bounds(value):
		return
	if value in blocked_cells:
		return
		
	path_start_position = value
	if path_end_position and path_end_position != path_start_position:
		_recalculate_path()

func _set_path_end_position(value) -> void:
	if is_outside_map_bounds(value):
		return
	if value in blocked_cells:
		return
		
	path_end_position = value
	if path_start_position != value:
		_recalculate_path()
