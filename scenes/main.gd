extends Node2D

@onready var gold_label: Label = $GUI/Resources/Gold/Label
@onready var wood_label: Label = $GUI/Resources/Wood/Label
@onready var meat_label: Label = $GUI/Resources/Meat/Label

var _commands = []

func _ready():
	pass

func _process(delta):
	gold_label.set_text(str(GameInstance.gold_amount))
	wood_label.set_text(str(GameInstance.wood_amount))
	meat_label.set_text(str(GameInstance.meat_amount))
