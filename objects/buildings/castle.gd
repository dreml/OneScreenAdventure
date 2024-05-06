extends Node2D

enum State {IDLE, UPDATING}

@export var meat_need_to_1 = 0
@export var wood_need_to_1 = 0
@export var gold_need_to_1 = 0
@export var meat_need_to_2 = 0
@export var wood_need_to_2 = 0
@export var gold_need_to_2 = 0
@export var update_time = 0

@onready var castle_sprite = $AnimatedSprite2D
@onready var _resource_required = [[meat_need_to_1, wood_need_to_1, gold_need_to_1], \
[meat_need_to_2, wood_need_to_2, gold_need_to_2]]
@onready var _buid_shape = get_node('AnimatedSprite2D/Area2D/BuildActivateShape2D')
@onready var _player = GameInstance.player
@onready var _pawn_scene = preload('res://npc/castle_pawn.tscn')
@onready var _pawns = $Pawns
@onready var _update_timer = $UpdateTimer
@onready var _resource_spent = $ResourcesSpent

var castle_level_act = 0
var _castle_level_max = 2
var _player_in_zone = false
var _castle_state = State.IDLE

func _ready():
	castle_sprite.play('level_0')
	_update_timer.set_wait_time(update_time)

func _on_area_2d_input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton and event.button_mask == 0 and _player_in_zone == true:
		if can_upgrate(castle_level_act):
			start_update()		

func can_upgrate(act_lvl):
	if act_lvl == _castle_level_max or _castle_state == State.UPDATING:
		return false
	return _resource_required[act_lvl][0] <= GameInstance.meat_amount and \
	_resource_required[act_lvl][1] <= GameInstance.wood_amount and \
	_resource_required[act_lvl][2] <= GameInstance.gold_amount

func start_update():
	_castle_state = State.UPDATING
	_update_timer.start()
	var pawn_inst = _pawn_scene.instantiate()
	pawn_inst.flip_h = true
	pawn_inst.position = Vector2(50, 50)
	_pawns.add_child(pawn_inst)
	resource_spending(castle_level_act)
	_resource_spent.wood = _resource_required[castle_level_act][1]
	_resource_spent.gold = _resource_required[castle_level_act][2]
	_resource_spent.meat = _resource_required[castle_level_act][0]
	_resource_spent.popup()
	
func upgrate():
	if castle_level_act == 0:
		_buid_shape.scale = Vector2(3,2)
	castle_level_act += 1
	castle_sprite.play('level_' + str(castle_level_act))
	
func _on_player_in_area_body_entered(body):
	if body == _player:
		_player_in_zone = true

func _on_player_in_area_body_exited(body):
	if body == _player:
		_player_in_zone = false

func _on_update_timer_timeout():
	upgrate()
	for i in _pawns.get_children():
		i.queue_free()
	_castle_state = State.IDLE

func resource_spending(act_lvl):
	GameInstance.meat_amount -= _resource_required[act_lvl][0]
	GameInstance.wood_amount -= _resource_required[act_lvl][1]
	GameInstance.gold_amount -= _resource_required[act_lvl][2]
