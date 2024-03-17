extends Node2D

# Declare member variables here. Examples:
# var a = 2
# var b = "text"
@onready var gold_label: Label = get_node('GoldLabel')
@onready var wood_label: Label = get_node('WoodLabel')
@onready var meat_label: Label = get_node('MeatLabel')

# Called when the node enters the scene tree for the first time.
func _ready():
	pass
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	gold_label.set_text(str(GameInstance.gold_amount))
	wood_label.set_text(str(GameInstance.wood_amount))
	meat_label.set_text(str(GameInstance.meat_amount))
