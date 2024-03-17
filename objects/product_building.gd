extends AnimatedSprite2D

class_name ProductBuilding

var storage_act = 0 # кол-во ресурса сейчас на складе
@export var storage_max = 0 # максимальный объем склада
@export var output = 0 # производительность за цикл
@export var output_time = 0 # время цикла производства
@onready var output_timer = $OutputTimer # экземпляр производственного таймера
@onready var gather_timer = $GatherTimer # экземпляр сборочного таймера
@export var gather_res_time = 0 # время сбора ресурса
var gather_start = false # флаг на активацию процедуры сбора
enum State {WORK, WAIT, DESTROYED} # возможные состояния здания
var state_act = State.WORK
var gatherer: Node2D = null # кто занял зону сбора
@export var res_sprite : PackedScene
@export var res_y = 0
@export var res_type : Globals.ResourceType

# Called when the node enters the scene tree for the first time.
func _ready():
	output_timer.set_wait_time(output_time)
	output_timer.start()
	gather_timer.set_wait_time(gather_res_time)
	print(name, res_type)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	state_change(state_act)
	if gather_start == true and gather_timer.is_stopped() and storage_act > 0:
		gather_timer.start()

func state_change(state):
	if state == State.WORK:
		play('production')			
	if state == State.WAIT:
		play('full_stock')		
	if state == State.DESTROYED:
		play("destroyed")
		
func production():
	for o in output: 
		if storage_act + 1 <= storage_max:
			storage_act += 1
		else: 
			storage_act = storage_max
			break
		var res_inst = res_sprite.instantiate()
		res_inst.position = Vector2(storage_act * 10, res_y)
		$Storage.add_child(res_inst)
		output_timer.start()
		if storage_act == storage_max:
			state_act = State.WAIT
			output_timer.stop()	

func resource_return():
	storage_act = 0
	for i in $Storage.get_children():
		i.queue_free()
	state_act = State.WORK
	output_timer.start()
	gather_timer.stop()
	
func resoure_bring(aim):
	aim.get_resourse(res_type, storage_act, gather_res_time)
	print('берем', res_type)
	$CollectSound.play()
	resource_return()
	gather_timer.stop()

func _on_gather_zone_body_entered(body):
	if body.has_method('get_resourse') and gatherer == null:
		gather_start = true
		gather_timer.start()	
		gatherer = body

func _on_gather_zone_body_exited(body):
	gather_start = false
	gather_timer.stop()
	gatherer = null

func _on_output_timer_timeout():
	production()
	
func _on_gather_timer_timeout():
	resoure_bring(gatherer)
