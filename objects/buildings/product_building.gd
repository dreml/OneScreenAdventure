extends Building
class_name ProductBuilding

enum ProducerState {WORK} # возможные состояния шахты

@onready var output_timer = $OutputTimer # экземпляр производственного таймера
@onready var gather_timer = $GatherTimer # экземпляр сборочного таймера
@onready var storage = $Storage # экз-ляр подсцены для размещ-я спрайтов ресов
@onready var gather_zone_shape: CollisionShape2D = $GatherZone/GatherZoneShape

@export var storage_max = 0 # максимальный объем склада
@export var output = 0 # производительность за цикл
@export var output_time = 0 # время цикла производства
@export var gather_res_time = 0 # время сбора ресурса
@export var res_sprite : PackedScene
@export var res_type : Globals.ResourceType 

var _storage_act = 0 # кол-во ресурса сейчас на складе
var _gatherer: Node2D = null # кто занял зону сбора

func _ready():
	_ANIMATIONS_BY_STATES = Helpers.merge([
		_ANIMATIONS_BY_STATES,
		{
			ProducerState.WORK: "production",
		}
	])

func _set_state(new_state):
	if new_state == _state:
		return

	super._set_state(new_state)
	
	match new_state:
		ProducerState.WORK:
			_start_production()
		State.DESTROYED:
			_stop_production()

func _start_production():
	output_timer.set_wait_time(output_time)
	output_timer.start()
	gather_timer.set_wait_time(gather_res_time)

func _stop_production():
	output_timer.stop()

func get_entrance():
	return gather_zone_shape.global_position

func produce():
	for o in output:
		if _storage_act >= storage_max:
			_storage_act = storage_max
			_set_state(State.IDLE)
			break  
		_storage_act += 1
		var res_inst = res_sprite.instantiate()
		res_inst.position = Vector2(_storage_act * 10, 0)
		storage.add_child(res_inst)
	if gather_timer_can_start():
		gather_timer.start()

func resource_return():
	_storage_act = 0
	for i in storage.get_children():
		i.queue_free()
		
	if _state == State.IDLE:
		_set_state(ProducerState.WORK)
	
func resoure_bring(target):
	target.get_resource(res_type, _storage_act)
	$CollectSound.play()
	resource_return()
	gather_timer.stop()

func _on_built():
	super._on_built()
	_set_state(ProducerState.WORK)

func _on_output_timer_timeout():
	produce()

func _on_gather_zone_body_entered(body):
	if body.has_method('get_resource') and _gatherer == null:
		gather_timer.start()
		_gatherer = body

func _on_gather_zone_body_exited(body):
	if body == _gatherer:
		gather_timer.stop()
		_gatherer = null
	
func _on_gather_timer_timeout():
	if _storage_act > 0:
		resoure_bring(_gatherer)

func gather_timer_can_start():
	return _gatherer != null and gather_timer.is_stopped() and _storage_act > 0
