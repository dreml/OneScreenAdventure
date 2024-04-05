extends Node

@onready var player: Player = get_tree().get_root().get_node('Main/Player') 
@onready var game_director: GameDirector = get_tree().get_root().get_node('Main/GameDirector')
@onready var main : Node2D = get_tree().get_root().get_node('Main')

var wood_amount := 0
var gold_amount := 0
var meat_amount := 0

func _ready() -> void:
	pass
	
func get_resource(type, amount):
	if type == Globals.ResourceType.GOLD_ORE:
		gold_amount += amount
	if type == Globals.ResourceType.WOOD:
		wood_amount += amount
	if type == Globals.ResourceType.MEAT:
		meat_amount += amount

func get_resource_from_container(dict):
	meat_amount += dict[Globals.ResourceType.MEAT]
	wood_amount += dict[Globals.ResourceType.WOOD]
	gold_amount += dict[Globals.ResourceType.GOLD_ORE]
