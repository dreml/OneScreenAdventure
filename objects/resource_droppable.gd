extends AnimatedSprite2D

class_name ResourceDroppable

enum State {DROP, BRING}

@onready var _gather_timer = $GatherTimer

@export var res_type : Globals.ResourceType
@export var res_qnt = 1
@export var output_time = 0.5

var _state_act = State.DROP
var _gatherer: Node2D = null # кто занял зону сбора
var _container = null

# Called when the node enters the scene tree for the first time.
func _ready():
	_gather_timer.set_wait_time(output_time)
	play("DROP")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
	
func _on_area_2d_body_entered(body):
	if body.has_method('get_resourse') and _gatherer == null:
		_gather_timer.start()	
		_gatherer = body
		
func resoure_bring(target):
	target.get_resourse(res_type, res_qnt)
	_gather_timer.stop()
	play("BRING")
	$BringSound.play()

func _on_gather_timer_timeout():
	resoure_bring(_gatherer)

func _on_bring_sound_finished():
	queue_free()

func set_container(container):
	_container = container

func clean_container(res_type, container):
	pass

func _on_area_2d_body_exited(body):
	if body == _gatherer:
		_gather_timer.stop()
		_gatherer = null
