class_name GameDirector
extends Node2D

@export var goblins: Array[Goblin]

@onready var attack_timer: Timer = $AttackTimer

var pawns_orders: Array[Command] = []

func _ready():
#	attack_timer.start()
	attack_timer.timeout.connect(move_goblins)
	
func _unhandled_input(event: InputEvent) -> void:
	if Input.is_key_pressed(KEY_T):
		attack_timer.start()

func _process(delta):
	pass

func move_goblins():
	for goblin in goblins:
		goblin.move_to(Vector2(600, 1500))

func create_order(order: Command):
	pawns_orders.append(order)
	
func take_order() -> Command:
	if has_orders():
		return pawns_orders.pop_front()
		
	return null

func has_orders() -> bool:
	return pawns_orders.size() > 0
