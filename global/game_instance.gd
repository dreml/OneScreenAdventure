extends Node

@onready var player: Player = get_tree().get_root().get_node('Main/Player') 
@onready var game_director: GameDirector = get_tree().get_root().get_node('Main/GameDirector') 

var wood_amount := 0
var gold_amount := 0
var meat_amount := 0

func _ready() -> void:
	pass
	
func get_resource(type, amount):
	match type:
		Globals.ResourceType.GOLD_ORE:
			gold_amount += amount
		Globals.ResourceType.WOOD:
			wood_amount += amount
		Globals.ResourceType.MEAT:
			meat_amount += amount

func spend_resource(type, amount):
	match type:
		Globals.ResourceType.GOLD_ORE:
			gold_amount -= amount
		Globals.ResourceType.WOOD:
			wood_amount -= amount
		Globals.ResourceType.MEAT:
			meat_amount -= amount
