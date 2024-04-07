extends AnimatedSprite2D

class_name ResourceContainer

enum State {CLOSED, OPENED}

@export var _meat_qnt = 0
@export var _wood_qnt = 0
@export var _gold_qnt = 0

@onready var _drop = $Drop
@onready var _delete_timer = $DeleteTimer
@onready var _gather_timer = $GatherTimer
@onready var _drop_butt_vis_timer = $DropButtonVisible
@onready var _drop_butt = $DropButton
@onready var _gatherer : Player = GameInstance.player
@onready var _container_list = {Globals.ResourceType.MEAT : _meat_qnt, Globals.ResourceType.WOOD : _wood_qnt, Globals.ResourceType.GOLD_ORE : _gold_qnt}

@export_file("*.tscn") var _meat_path : String
@export_file("*.tscn") var _wood_path : String
@export_file("*.tscn") var _gold_path : String

var _res_scene_list = []
var _state_act = State.CLOSED

func _ready():
	state_change(State.CLOSED)
	load_resources()

#func _process(delta):
	#pass

func load_resources():
	load_res_scene(_meat_qnt, _meat_path)
	load_res_scene(_wood_qnt, _wood_path)
	load_res_scene(_gold_qnt, _gold_path)
	
func load_res_scene(qnt, path):
	var res
	if qnt > 0:
		res = load(path)
		for n in qnt:
			_res_scene_list.append(res)	
	
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
		var res_inst = i.instantiate()
		res_inst.set_container(true)
		res_inst.play("DROP")
		res_inst.position = Vector2(randi() % 5 + (k * randi() % 20), randi() % 20)
		k += 1
		_drop.call_deferred("add_child", res_inst)
		
	_gather_timer.start()
		
func bring_resources(target):
	target.get_resource_from_container(_container_list)
	for i in _drop.get_children():
		i.play('BRING')
		i.bring_sound.play()
	_delete_timer.start()

func _on_delete_timer_timeout():
	queue_free()	

func _on_drop_button_pressed():
	drop_resources()
	_drop_butt.visible = false

func _on_gather_zone_body_entered(body):
	if body == GameInstance.player and _state_act == State.CLOSED:
		_drop_butt_vis_timer.start()
		
func _on_drop_button_visible_timeout():
	_drop_butt.visible = true

func _on_gather_zone_body_exited(body):
	if body.name == "Player":
		_drop_butt_vis_timer.stop()
		_drop_butt.visible = false

func _on_gather_timer_timeout():
	bring_resources(_gatherer)
