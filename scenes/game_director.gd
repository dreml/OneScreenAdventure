class_name GameDirector
extends Node2D

@export var goblins: Array[Goblin]

@onready var attack_timer: Timer = $AttackTimer

# Called when the node enters the scene tree for the first time.
func _ready():
#	attack_timer.start()
	attack_timer.timeout.connect(move_goblins)
	
func _unhandled_input(event: InputEvent) -> void:
	if Input.is_key_pressed(KEY_T):
		attack_timer.start()
	
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func move_goblins():
	for goblin in goblins:
		goblin.move_to(Vector2(600, 1500))