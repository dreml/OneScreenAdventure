extends AnimatedSprite2D

class_name ProductBuilding

enum State {WORK, WAIT, DESTROYED} # возможные состояния здания

@onready var output_timer = $OutputTimer # экземпляр производственного таймера
@onready var gather_timer = $GatherTimer # экземпляр сборочного таймера
@onready var storage = $Storage # экз-ляр подсцены для размещ-я спрайтов ресов

@export var storage_max = 0 # максимальный объем склада
@export var output = 0 # производительность за цикл
@export var output_time = 0 # время цикла производства
@export var gather_res_time = 0 # время сбора ресурса
@export var res_sprite : PackedScene
@export var res_y = 0
@export var res_type : Globals.ResourceType 

var _storage_act = 0 # кол-во ресурса сейчас на складе
var _state_act = null
var _gatherer: Node2D = null # кто занял зону сбора

func _ready():
	output_timer.set_wait_time(output_time)
	output_timer.start()
	gather_timer.set_wait_time(gather_res_time)
	state_change(State.WORK)

func state_change(state):
	if state == _state_act:
		return
	
	_state_act = state
	if _state_act == State.WORK:
		play('production')
		output_timer.start()			
	if _state_act == State.WAIT:
		play('full_stock')
		output_timer.stop()		
	if _state_act == State.DESTROYED:
		play("destroyed")
		output_timer.stop()
			
func production():
	for o in output:
		if _storage_act >= storage_max:
			_storage_act = storage_max
			state_change(State.WAIT)
			break  
		_storage_act += 1
		var res_inst = res_sprite.instantiate()
		res_inst.position = Vector2(_storage_act * 10, res_y)
		storage.add_child(res_inst)
	if gather_timer_can_start():
		gather_timer.start()

func resource_return():
	_storage_act = 0
	for i in storage.get_children():
		i.queue_free()
	state_change(State.WORK)
	
func resoure_bring(target):
	target.get_resource(res_type, _storage_act)
	$CollectSound.play()
	resource_return()
	gather_timer.stop()

func _on_gather_zone_body_entered(body):
	print(body)
	if body.has_method('get_resource') and _gatherer == null:
		gather_timer.start()	
		_gatherer = body

func _on_gather_zone_body_exited(body):
	if body == _gatherer:
		gather_timer.stop()
		_gatherer = null

func _on_output_timer_timeout():
	production()
	
func _on_gather_timer_timeout():
	resoure_bring(_gatherer)

func gather_timer_can_start():
	return _gatherer != null and gather_timer.is_stopped() and _storage_act > 0		
