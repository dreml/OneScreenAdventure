class_name Building
extends StaticBody2D

signal constructed

@export var hp: float
@export var gold_requires: int
@export var wood_requires: int

var _hp_left = 0

func start_building() -> void:
	$AnimationPlayer.play("construction")

func build(hp_to_add: float) -> void:
	_hp_left = min(_hp_left + hp_to_add, hp)
	
	if _hp_left == hp:
		$AnimationPlayer.play("idle")
		constructed.emit()
	
func destroy(damage: float) -> void:
	_hp_left = max(_hp_left - damage, 0)
	
	if _hp_left == 0:
		$AnimationPlayer.play("destroyed")

func get_rect_global() -> Rect2:
	var collision = $CollisionShape2D
	var result = $CollisionShape2D.shape.get_rect()
	
	result.position = global_position + collision.position
	return result
