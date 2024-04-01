extends Node2D

func wrap_around(shape: Rect2):
	_set_boundaries(shape.size / 2.0)

func reset():
	_set_boundaries(Vector2.ZERO)

func _set_boundaries(shift: Vector2):
	$TopLeft.position.x = -1.0 * shift.x
	$TopLeft.position.y = -1.0 * shift.y

	$TopRight.position.x = shift.x
	$TopRight.position.y = -1.0 * shift.y
	
	$BottomLeft.position.x = -1.0 * shift.x
	$BottomLeft.position.y = shift.y
	
	$BottomRight.position.x = shift.x
	$BottomRight.position.y = shift.y
	
