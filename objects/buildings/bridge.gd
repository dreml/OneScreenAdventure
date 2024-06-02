extends Building
class_name Bridge

@onready var entrance_point = $entrance_point

func _on_built():
	animation_player.play("building_animations/construction_end")
	await animation_player.animation_finished
	super._on_built()
	GameInstance.build_bridge()
	queue_free()

func get_entrance():
	return position + entrance_point.position
