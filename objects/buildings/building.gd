class_name Building
extends StaticBody2D

signal constructed
signal dead

enum State { CONSTRUCTION = 100, IDLE = 101, DESTROYED = 102 }
const ANIMATION_NAME_TEMPLATE = "building_animations/%s"
var _ANIMATIONS_BY_STATES = {
	State.CONSTRUCTION: ANIMATION_NAME_TEMPLATE % "construction",
	State.IDLE: ANIMATION_NAME_TEMPLATE % "idle",
	State.DESTROYED: ANIMATION_NAME_TEMPLATE % "destroyed"
}

@export var gold_requires: int
@export var meat_requires: int
@export var wood_requires: int
@export var global_rect_adjustment: Vector2

@onready var health_component: HealthComponent = $HealthComponent
@onready var resources_spent = $ResourcesSpent
@onready var foundation: CollisionShape2D = $Foundation
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var constructed_sound: AudioStreamPlayer2D = $ConstructedSound

var _state = State.DESTROYED

func _ready():
	health_component.dead.connect(func(): dead.emit())

func start_building() -> bool:
	if !_is_enough_resources() && !is_constructed():
		animation_player.play(ANIMATION_NAME_TEMPLATE % "construction_forbidden")

	if !can_be_built():
		return false

	resources_spent.gold = gold_requires
	resources_spent.meat = meat_requires
	resources_spent.wood = wood_requires

	GameInstance.spend_resource(Globals.ResourceType.WOOD, wood_requires)
	GameInstance.spend_resource(Globals.ResourceType.MEAT, meat_requires)
	GameInstance.spend_resource(Globals.ResourceType.GOLD_ORE, gold_requires)

	_set_state(State.CONSTRUCTION)

	return true

func build(hp_to_add: int) -> void:
	health_component.add_health(hp_to_add)

func take_damage(damage: int) -> void:
	health_component.take_damage(damage)

func get_rect_global() -> Rect2:
	var result = foundation.shape.get_rect()
	result.position = global_position + foundation.position + global_rect_adjustment

	return result

func get_entrance():
	var rect = get_rect_global()

	return rect.position + Vector2(0, rect.size.y)

func _set_state(state: State):
	_state = state
	if not self is Bridge:
		animation_player.play(_ANIMATIONS_BY_STATES[state])

func _on_built():
	_set_state(State.IDLE)
	constructed.emit()
	constructed_sound.play()

func _on_destroyed():
	_set_state(State.DESTROYED)

func can_be_built():
	return !is_constructed() && _is_enough_resources()

func is_constructed():
	return _state != State.DESTROYED

func _is_enough_resources():
	var is_enough_wood = GameInstance.wood_amount >= wood_requires
	var is_enough_meat = GameInstance.meat_amount >= meat_requires
	var is_enough_gold = GameInstance.gold_amount >= gold_requires

	return is_enough_gold && is_enough_meat && is_enough_wood
