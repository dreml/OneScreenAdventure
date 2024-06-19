extends Node

signal goblin_dead

signal sawmill_built
signal sawmill_destroyed
signal farm_built
signal farm_destroyed
signal gold_mine_built
signal gold_mine_destroyed

@onready var player: Player = get_tree().get_root().get_node('Main/Player')
@onready var game_director: GameDirector = get_tree().get_root().get_node('Main/GameDirector')
@onready var main: Node2D = get_tree().get_root().get_node('Main')
@onready var hud: CanvasLayer = get_tree().get_root().get_node('Main/HUD');
@onready var level = get_tree().get_root().get_node('Main/level');
@onready var navigation_map = get_tree().get_root().get_node('Main/NavigationMap');

var wood_amount := 10
var gold_amount := 10
var meat_amount := 10

func _ready() -> void:
	player.dead.connect(func(): print('player is dead'))

func get_resource(type, amount):
	match type:
		Globals.ResourceType.GOLD_ORE:
			gold_amount += amount
		Globals.ResourceType.WOOD:
			wood_amount += amount
		Globals.ResourceType.MEAT:
			meat_amount += amount

func get_resource_from_container(dict):
	meat_amount += dict[Globals.ResourceType.MEAT]
	wood_amount += dict[Globals.ResourceType.WOOD]
	gold_amount += dict[Globals.ResourceType.GOLD_ORE]

func spend_resource(type, amount):
	match type:
		Globals.ResourceType.GOLD_ORE:
			gold_amount -= amount
		Globals.ResourceType.WOOD:
			wood_amount -= amount
		Globals.ResourceType.MEAT:
			meat_amount -= amount

func show_build_popup(building: Building):
	if hud.is_build_popup_hidden():
		hud.show_build_popup(building)

func building_built(building: ProductBuilding):
	match building.res_type:
		Globals.ResourceType.GOLD_ORE:
			gold_mine_built.emit()
		Globals.ResourceType.WOOD:
			sawmill_built.emit()
		Globals.ResourceType.MEAT:
			farm_built.emit()

func building_destroyed(building: ProductBuilding):
	match building.res_type:
		Globals.ResourceType.GOLD_ORE:
			gold_mine_destroyed.emit()
		Globals.ResourceType.WOOD:
			sawmill_destroyed.emit()
		Globals.ResourceType.MEAT:
			farm_destroyed.emit()

func build_bridge():
	navigation_map.build_bridge()
	level.build_bridge()
