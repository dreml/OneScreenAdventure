class_name Camp
extends Node2D

signal goblin_delivered_resources
signal goblin_dead

enum GoblinType {
	FIGHTER,
	BOMBER
}

@export var goblin_fighter_prototype: PackedScene
@export var goblin_bomber_prototype: PackedScene

@onready var portal: Node2D = $Portal
@onready var rally_point: Node2D = $RallyPoint
@onready var prepare_attack_timer: Timer = $PrepareAttackTimer

@onready var GOBLIN_PROTOTYPE_BY_TYPE: Dictionary = {
	GoblinType.FIGHTER: goblin_fighter_prototype,
	GoblinType.BOMBER: goblin_bomber_prototype,
} 

var goblins: Array[Goblin]

func steal_resource(target_building: ProductBuilding):
	var goblin := _spawn_goblin(GoblinType.FIGHTER)
	prepare_attack_timer.timeout.connect(func(): goblin.steal_resource(target_building), Object.CONNECT_ONE_SHOT)
	prepare_attack_timer.start()

func attack_building(target_building: Building):
	var goblin := _spawn_goblin(GoblinType.FIGHTER)
	prepare_attack_timer.timeout.connect(func(): goblin.attack_building(target_building), Object.CONNECT_ONE_SHOT)
	prepare_attack_timer.start()

func attack_tower(target_tower: Tower):
	var goblin = _spawn_goblin(GoblinType.BOMBER) as GoblinBomber
	prepare_attack_timer.timeout.connect(func(): goblin.attack_building(target_tower), Object.CONNECT_ONE_SHOT)
	prepare_attack_timer.start()

func handle_goblin_delivered_resources(goblin: Goblin):
	goblin_delivered_resources.emit()
	handle_goblin_return_to_portal(goblin)

func handle_goblin_return_to_portal(goblin: Goblin):
	goblin.queue_free()

func _spawn_goblin(type: GoblinType) -> Goblin:
	var goblin = GOBLIN_PROTOTYPE_BY_TYPE[type].instantiate() as Goblin
	GameInstance.main.add_child(goblin)

	goblin.home_camp = self
	goblin.global_position = portal.global_position
	goblin.move_to(rally_point.global_position)

	return goblin
