class_name Pointer
extends Node2D

var _default_position := Vector2(-100, -100)

func wrap_around(shape: Node2D):
	var shift := Vector2.ZERO
	var new_position = shape.position
	if shape.has_method('get_rect_global'):
		shift = shape.get_rect_global().size / 2.0
		new_position = shape.get_rect_global().position

	_set_boundaries(shift)
	position = new_position

func reset():
	_set_boundaries(Vector2.ZERO)
	position = _default_position

func _set_boundaries(shift: Vector2):
	$TopLeft.position.x = -1.0 * shift.x
	$TopLeft.position.y = -1.0 * shift.y

	$TopRight.position.x = shift.x
	$TopRight.position.y = -1.0 * shift.y
	
	$BottomLeft.position.x = -1.0 * shift.x
	$BottomLeft.position.y = shift.y
	
	$BottomRight.position.x = shift.x
	$BottomRight.position.y = shift.y
	
