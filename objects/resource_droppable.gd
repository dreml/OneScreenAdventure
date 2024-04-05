extends AnimatedSprite2D

class_name ResourceDroppable

@onready var _gather_timer = $GatherTimer
@onready var bring_sound = $BringSound

@export var res_type : Globals.ResourceType
@export var res_qnt = 1
@export var output_time = 0.5

var _gatherer: Node2D = null # кто занял зону сбора
var _container = false # проверка ресурса на самостоятельность

func _ready():
	if _container:
		return
	_gather_timer.set_wait_time(output_time)
	play("DROP")

#func _process(delta):
	#pass
	
func _on_area_2d_body_entered(body):
	print("Зона")
	print(_container)
	if _container:
		return
	if body.has_method('get_resource') and _gatherer == null:
		_gather_timer.start()	
		_gatherer = body
		print(_gatherer)
		
func resoure_bring(target):
	target.get_resource(res_type, res_qnt)
	_gather_timer.stop()
	play("BRING")
	bring_sound.play()

func _on_gather_timer_timeout():
	resoure_bring(_gatherer)

func _on_bring_sound_finished():
	queue_free()

func set_container(state):
	_container = state

func _on_area_2d_body_exited(body):
	if _container:
		return
	if body == _gatherer:
		_gather_timer.stop()
		_gatherer = null
	
