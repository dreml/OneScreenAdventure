class_name GameDirector
extends Node2D

@export var sawmill: ProductBuilding
@export var farm: ProductBuilding
@export var gold_mine: ProductBuilding

@export var camp1: Camp
@export var camp2: Camp

@onready var camp1_attack_timer: Timer = $Camp1AttackTimer
@onready var camp2_attack_timer: Timer = $Camp2AttackTimer

var pawns_orders: Array[Command] = []

var camp1_goblin_death_count := 0
var camp2_goblin_death_count := 0

var camp1_target: Building
var camp2_target: Building

func _ready():
	GameInstance.sawmill_built.connect(handle_sawmill_built)
	GameInstance.farm_built.connect(handle_farm_built)
	
	camp1_target = sawmill
	camp1_attack_timer.timeout.connect(func(): camp1.steal_resource(camp1_target))
	camp1.goblin_delivered_resources.connect(func(): camp1_attack_timer.start())
	camp1.goblin_dead.connect(handle_camp1_goblin_death)

	camp2_target = farm
	camp2_attack_timer.timeout.connect(func(): camp2.steal_resource(camp2_target))
	camp2.goblin_dead.connect(handle_camp2_goblin_death)
	
func _unhandled_input(_event: InputEvent) -> void:
	pass

#region pawns
func create_order(order: Command):
	pawns_orders.append(order)
	
func take_order() -> Command:
	if has_orders():
		return pawns_orders.pop_front()
		
	return null

func has_orders() -> bool:
	return pawns_orders.size() > 0
#endregion

#region goblins
func handle_camp1_goblin_death():
	camp1_goblin_death_count += 1
	camp1_attack_timer.start()

func handle_camp2_goblin_death():
	camp2_goblin_death_count += 1
	camp2_attack_timer.start()

func handle_sawmill_built():
	camp1_attack_timer.start()

func handle_farm_built():
	camp2_attack_timer.start()
#endregion
