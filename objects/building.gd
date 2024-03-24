class_name Building
extends StaticBody2D

signal constructed

enum State {FOUNDATION, CONSTRUCTION, IDLE, DESTROYED}
const _resource_spent_template = "-%s"
const _forbidden_color = Color("#ff6a43")

@export var hp: float
@export var gold_requires: int
@export var wood_requires: int
@export var global_rect_adjustment: Vector2

var _hp_left = 0
var _state = State.FOUNDATION
var _default_modulation = self.modulate

func _process(_delta):
	if _state == State.FOUNDATION:
		self.modulate = _forbidden_color if !_can_be_built() else _default_modulation

func start_building() -> bool:
	var is_appropriate_state = _state == State.FOUNDATION || _state == State.DESTROYED
	
	if !is_appropriate_state || !_can_be_built():
		return false

	$GoldSpent/Label.set_text(_resource_spent_template % str(gold_requires))
	$WoodSpent/Label.set_text(_resource_spent_template % str(wood_requires))
	
	GameInstance.wood_amount -= wood_requires
	GameInstance.gold_amount -= gold_requires
	
	$AnimationPlayer.play("construction")
	_state = State.CONSTRUCTION
	
	return true

func build(hp_to_add: float) -> void:
	_hp_left = min(_hp_left + hp_to_add, hp)
	
	if _hp_left == hp:
		$AnimationPlayer.play("idle")
		_state = State.IDLE
		constructed.emit()
	
func destroy(damage: float) -> void:
	_hp_left = max(_hp_left - damage, 0)
	
	if _hp_left == 0:
		$AnimationPlayer.play("destroyed")
		_state = State.DESTROYED

func get_rect_global() -> Rect2:
	var result = $CollisionShape2D.shape.get_rect()
	result.position = global_position + $CollisionShape2D.position + global_rect_adjustment

	return result
	
func get_entrance():
	var rect = get_rect_global()
	
	return global_position + Vector2(0, rect.size.y * 2)

func _can_be_built():
	var is_enough_wood = GameInstance.wood_amount >= wood_requires
	var is_enough_gold = GameInstance.gold_amount >= gold_requires
	
	return is_enough_gold && is_enough_wood
