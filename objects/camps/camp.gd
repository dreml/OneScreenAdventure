class_name Camp
extends Node2D

signal goblin_delivered_resources
signal goblin_dead

@export var goblin_prototype: PackedScene

@onready var portal: Node2D = $Portal
@onready var rally_point: Node2D = $RallyPoint
@onready var prepare_attack_timer: Timer = $PrepareAttackTimer

var goblins: Array[Goblin]

func steal_resource(target_building: ProductBuilding):
	var goblin = goblin_prototype.instantiate() as Goblin
	GameInstance.main.add_child(goblin)

	# goblins.append(goblin)
	goblin.home_camp = self
	goblin.global_position = portal.global_position
	goblin.move_to(rally_point.global_position)

	prepare_attack_timer.timeout.connect(func(): goblin.steal_resource(target_building), Object.CONNECT_ONE_SHOT)
	prepare_attack_timer.start()

func handle_goblin_delivered_resources(goblin: Goblin):
	goblin_delivered_resources.emit()
	goblin.queue_free()
