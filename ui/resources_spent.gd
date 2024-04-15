extends Control

const _resource_spent_template = "-%s"

@export var gold := 0:
	set(new_value):
		gold_spent_label.set_text(_resource_spent_template % str(new_value))
		gold = new_value
@export var wood := 0:
	set(new_value):
		wood_spent_label.set_text(_resource_spent_template % str(new_value))
		wood = new_value

@onready var gold_spent_label: Label = $Gold/Label
@onready var wood_spent_label: Label = $Wood/Label
@onready var animation_player: AnimationPlayer = $AnimationPlayer

func popup():
	animation_player.play("popup")
