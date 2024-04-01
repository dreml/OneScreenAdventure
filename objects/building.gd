class_name Building
extends StaticBody2D

signal constructed

enum State { FOUNDATION, CONSTRUCTION, IDLE, DESTROYED }
const _ANIMATIONS_BY_STATES = {
	State.FOUNDATION: "foundation",
	State.CONSTRUCTION: "construction",
	State.IDLE: "idle",
	State.DESTROYED: "destroyed"
}
const _resource_spent_template = "-%s"
const _forbidden_color = Color("#ff6a43")

@export var hp: float
@export var gold_requires: int
@export var wood_requires: int
@export var global_rect_adjustment: Vector2

@onready var health_component: HealthComponent = $HealthComponent
@onready var gold_spent_label: Label = $GoldSpent/Label
@onready var wood_spent_label: Label = $WoodSpent/Label
@onready var collision_shape: CollisionShape2D = $CollisionShape2D
@onready var animation_player: AnimationPlayer = $AnimationPlayer

var _state = State.FOUNDATION
var _default_modulation = self.modulate

func _process(_delta):
	if !_is_constructed():
		self.modulate = _forbidden_color if !_is_enough_resources() else _default_modulation

func start_building() -> bool:
	if !_can_be_built():
		return false

	gold_spent_label.set_text(_resource_spent_template % str(gold_requires))
	wood_spent_label.set_text(_resource_spent_template % str(wood_requires))
	
	GameInstance.spend_resource(Globals.ResourceType.WOOD, wood_requires)
	GameInstance.spend_resource(Globals.ResourceType.GOLD_ORE, gold_requires)
	
	_set_state(State.CONSTRUCTION)
	
	return true

func build(hp_to_add: int) -> void:
	health_component.add_health(hp_to_add)

func destroy(damage: int) -> void:
	health_component.take_damage(damage)

func get_rect_global() -> Rect2:
	var result = collision_shape.shape.get_rect()
	result.position = global_position + collision_shape.position + global_rect_adjustment

	return result
	
func get_entrance():
	var rect = get_rect_global()
	
	return global_position + Vector2(0, rect.size.y * 2)

func _set_state(state: State):
	_state = state
	animation_player.play(_ANIMATIONS_BY_STATES[state])

func _on_built():
	_set_state(State.IDLE)
	constructed.emit()

func _on_destroyed():
	_set_state(State.DESTROYED)

func _can_be_built():
	return !_is_constructed() && _is_enough_resources()
	
func _is_constructed():
	return _state != State.FOUNDATION && _state != State.DESTROYED

func _is_enough_resources():
	var is_enough_wood = GameInstance.wood_amount >= wood_requires
	var is_enough_gold = GameInstance.gold_amount >= gold_requires
	
	return is_enough_gold && is_enough_wood
