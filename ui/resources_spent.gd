extends Control

const _resource_spent_template = "-%s"

@export var gold := 0:
	set(new_value):
		gold_spent_label.set_text(_resource_spent_template % str(new_value))
		gold = new_value
@export var meat := 0:
	set(new_value):
		meat_spent_label.set_text(_resource_spent_template % str(new_value))
		meat = new_value
@export var wood := 0:
	set(new_value):
		wood_spent_label.set_text(_resource_spent_template % str(new_value))
		wood = new_value

@onready var gold_spent_label: Label = $Gold/Label
@onready var gold_anim: AnimationPlayer = $Gold/AnimationGold
@onready var meat_spent_label: Label = $Meat/Label
@onready var meat_anim: AnimationPlayer = $Meat/AnimationMeat
@onready var wood_spent_label: Label = $Wood/Label
@onready var wood_anim: AnimationPlayer = $Wood/AnimationWood

var playlist = [];

func popup():
	if gold > 0:
		playlist.push_back(gold_anim)
	if meat > 0:
		playlist.push_back(meat_anim)
	if wood > 0:
		playlist.push_back(wood_anim)
	_on_play_next("popup")

# Без параметра не будет работать animation_finished.connect
func _on_play_next(anim_name: String):
	var anim = playlist.pop_front()

	if anim != null:
		anim.play(anim_name)
		# Подписываться надо на animation_finished именно после запуска анимации, иначе событие не сработает
		anim.animation_finished.connect(_on_play_next, Object.CONNECT_ONE_SHOT)
