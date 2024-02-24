extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
@onready var GoldLabel: Label = get_node('GoldLabel')
@onready var WoodLabel: Label = get_node('WoodLabel')
@onready var Player : Node2D = get_node('Player')

# Called when the node enters the scene tree for the first time.
func _ready():
	pass
	#var GoldLabel: Label = get_node('GoldLabel')
	#var Player : Node2D = get_node('Player')
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	GoldLabel.set_text(str(Player.gold_ore_amount))
	WoodLabel.set_text(str(Player.wood_amount))
