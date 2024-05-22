extends Building
class_name Bridge

@onready var collision = $CollisionShape2D
@onready var entrance_point = $entrance_point

func _on_built():
	super._on_built()
	GameInstance.build_bridge()
	queue_free()

func get_entrance():
	return position + entrance_point.position
