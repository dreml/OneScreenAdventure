extends AnimatedSprite2D
var sawmill_storage_act = 0 # кол-во ресурса сейчас на складе
var sawmill_storage_max = 5 # максимальный объем склада
var sawmill_output = 1 # производительность за цикл
var output_time = 2 # время цикла производства
@onready var output_timer = $OutputTimer # экземпляр производственного таймера
@onready var gather_timer = $GatherTimer # экземпляр сборочного таймера
var sawmill_hp = 100
var sawmill_lvl = 1
var gather_res_time = 1 # время сбора ресурса
var gather_start = false # флаг на активацию процедуры сбора
enum State {WORK, WAIT, DESTROYED}
var sawmill_state_act = State.WORK
var in_production = 0 # текущее время цикла в сек
var in_gather = 0 # текущее время сбора ресурсов в сек
var gatherer: Node2D = null # кто занял зону сбора
var wood = load('res://objects/wood.tscn')

# Called when the node enters the scene tree for the first time.
func _ready():
	output_timer.start()
	gather_timer.start()
	gather_timer.set_paused(true)
	var sawmill_coord = get_indexed('position')

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	state_change(sawmill_state_act)
	if gather_start==true:
		resoure_bring(gatherer)

func mine_production():
	sawmill_storage_act += sawmill_output
	#print("Now is ", mine_storage_act)
	in_production = 0
	var wood = wood.instantiate()
	wood.position = Vector2(sawmill_storage_act*10,50)
	$Storage.add_child(wood)
	#mine_storage_list.append(ore)
	if sawmill_storage_act == sawmill_storage_max:
		sawmill_state_act = State.WAIT
		#print('stock is full')
		output_timer.set_paused(true)			
	
func state_change(state):
	if state == State.WORK:
		play('production')
		if in_production == output_time:
			mine_production()		
	if state == State.WAIT:
		play('full_stock')	
	if state == State.DESTROYED:
		play("destroyed")
		
func get_player_coord_and_state():
	pass
	
func resource_return():
	sawmill_storage_act = 0
	in_production = 0
	for i in $Storage.get_children():
		i.queue_free()
	sawmill_state_act = State.WORK
	output_timer.set_paused(false)
	in_gather=0
	gather_timer.set_paused(true)
					
func _on_gather_zone_body_entered(body:Node2D):
	print('объект в зоне')
	if body.has_method('get_resourse') and gatherer == null:
		print('Объект может собрать')
		gather_start=true
		print(gather_start)
		gatherer=body
		print('собиратель: ',gatherer)
		
func resoure_bring(aim):
	if sawmill_storage_act>0:
		gather_timer.set_paused(false)
		if in_gather == gather_res_time:
			#gather_timer.set_paused(true)
			in_gather=0
			print('сбор!!!')
			aim.get_resourse('wood', sawmill_storage_act, gather_res_time)
			$WoodCollectSound.play()
			resource_return()

func _on_gather_timer_timeout():
	in_gather +=1
	print('сбор:', in_gather)
	
func _on_gather_zone_body_exited(body):
	gather_start=false
	gather_timer.set_paused(true)
	in_gather=0
	gatherer = null
	print('собиратель: ',gatherer)
	



func _on_output_timer_timeout():
	in_production +=1
	#print(in_production)


func _on_gather_zone_body_shape_entered(body_rid, body, body_shape_index, local_shape_index):
	pass # Replace with function body.
