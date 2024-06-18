class_name GameDirector
extends Node2D

@export var sawmill: ProductBuilding
@export var farm: ProductBuilding
@export var gold_mine: ProductBuilding
@export var tower1: Tower
@export var tower2: Tower

@export var pawn_scene: PackedScene
@export var pawn_spawn_point: Node2D

@export var camp1: Camp
@export var camp2: Camp

@export var goblin_deaths_to_bomber := 10

@onready var camp1_attack_timer: Timer = $Camp1AttackTimer
@onready var camp1_bomber_spawn_timer: Timer = $Camp1BomberSpawnTimer
@onready var camp2_attack_timer: Timer = $Camp2AttackTimer
@onready var camp2_bomber_spawn_timer: Timer = $Camp2BomberSpawnTimer

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
	camp1_bomber_spawn_timer.timeout.connect(func(): camp1.attack_tower(tower1))
	camp1.goblin_delivered_resources.connect(func(): camp1_attack_timer.start())
	camp1.goblin_dead.connect(handle_camp1_goblin_death)

	camp2_target = farm
	camp2_attack_timer.timeout.connect(func(): camp2.steal_resource(camp2_target))
	camp2_bomber_spawn_timer.timeout.connect(func(): camp2.attack_tower(tower2))
	camp2.goblin_dead.connect(handle_camp2_goblin_death)
	camp2.goblin_delivered_resources.connect(func(): camp2_attack_timer.start())
	
func _unhandled_input(_event: InputEvent) -> void:
	if Input.is_key_pressed(KEY_T):
		camp1_attack_timer.stop()
		camp1.attack_building(camp1_target)
	elif Input.is_key_pressed(KEY_V):
		camp2_attack_timer.stop()
		camp2.attack_tower(tower2)


#region pawns
func create_order(order: Command):
	if !get_tree().get_nodes_in_group("pawns").any(func(p): return p.is_idle()):
		var pawn = pawn_scene.instantiate()
		pawn.position = pawn_spawn_point.position
		add_child(pawn)
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
	if camp1_goblin_death_count == goblin_deaths_to_bomber:
		camp1_bomber_spawn_timer.start()
		camp1_goblin_death_count = 0
	else:
		camp1_attack_timer.start()

func handle_camp2_goblin_death():
	camp2_goblin_death_count += 1
	if camp2_goblin_death_count == goblin_deaths_to_bomber:
		camp2_bomber_spawn_timer.start()
		camp2_goblin_death_count = 0
	else:
		camp2_attack_timer.start()

func handle_sawmill_built():
	camp1_attack_timer.start()

func handle_farm_built():
	camp2_attack_timer.start()
#endregion
