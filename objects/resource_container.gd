extends AnimatedSprite2D

class_name ResourceContainer

enum State {CLOSED, OPENED}

@onready var _drop = $Drop
@onready var _delete_timer = $DeleteTimer
@onready var _drop_butt_vis_timer = $DropButtonVisible
@onready var main = get_tree().get_root().get_node('Main')
@onready var _drop_butt = $DropButton

@export var _meat_qnt = 0
@export var _wood_qnt = 0
@export var _gold_qnt = 0

var _container_list = [_meat_qnt, _wood_qnt, _gold_qnt]
var _res_scene_list = []
var _res_type_list = []
var _state_act = State.CLOSED
var _gatherer = null


func _ready():
	state_change(State.CLOSED)
	load_resources()
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func load_resources():
	load_res_scene(Globals.ResourceType.MEAT, _meat_qnt, "res://objects/meat_drop.tscn")
	load_res_scene(Globals.ResourceType.WOOD, _wood_qnt, "res://objects/wood_drop.tscn")
	load_res_scene(Globals.ResourceType.GOLD_ORE, _gold_qnt, "res://objects/gold_ore_drop.tscn")
	
func load_res_scene(res_type, qnt, path):
	var res
	if qnt > 0:
		res = load(path)
		for n in qnt:
			_res_scene_list.append(res)
			_res_type_list.append(res_type)
	
func state_change(state):
	_state_act = state	
	if _state_act == State.CLOSED:
		play('CLOSED')
		
	if _state_act == State.OPENED:
		play("OPENED")
		$DropSound.play()
		
func drop_resources():
	state_change(State.OPENED)
	var k = 0
	for i in _res_scene_list:
		k += 1
		var res_inst = i.instantiate()
		res_inst.position = Vector2(global_position.x + (k * 10), global_position.y)
		main.call_deferred("add_child", res_inst)
		
	$DeleteTimer.start()
		
func bring_resources(target):
	pass

func clean_container(res_type):
	_res_type_list.erase(res_type)

func _on_delete_timer_timeout():
	queue_free()	

func _on_drop_button_pressed():
	drop_resources()
	_drop_butt.visible = false

func _on_gather_zone_body_entered(body):
	if body.name == "Player" and _state_act == State.CLOSED:
		_drop_butt_vis_timer.start()
		
func _on_drop_button_visible_timeout():
	_drop_butt.visible = true

func _on_gather_zone_body_exited(body):
	if body.name == "Player":
		_drop_butt_vis_timer.stop()
		_drop_butt.visible = false
