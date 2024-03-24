extends Node

@onready var player: Player = get_tree().get_root().get_node('Main/Player') 
@onready var game_director: GameDirector = get_tree().get_root().get_node('Main/GameDirector') 

var wood_amount := 0
var gold_amount := 0
var meat_amount := 0

var pawns_orders := []

func _ready() -> void:
	pass
	
func get_resource(type, amount):
	if type == Globals.ResourceType.GOLD_ORE:
		gold_amount += amount
	if type == Globals.ResourceType.WOOD:
		wood_amount += amount
	if type == Globals.ResourceType.MEAT:
		meat_amount += amount
