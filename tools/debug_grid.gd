@tool
extends Node2D

@export var map_size: Vector2 = Vector2.ONE * 16
@export var cell_size: int = 64

func _draw() -> void:
	for x in range(map_size.x - 1):
		draw_line(Vector2(cell_size * (x + 1), 0), Vector2(cell_size * (x + 1), map_size.y * cell_size), Color.WHITE, 2)
		
	for y in range(map_size.y - 1):
		draw_line(Vector2(0, cell_size * (y + 1)), Vector2(map_size.x * cell_size, cell_size * (y + 1)), Color.WHITE, 2)
