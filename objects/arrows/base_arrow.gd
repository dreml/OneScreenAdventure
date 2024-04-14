extends CharacterBody2D

class_name BaseArrow

@export var damage = 0 # урон от стрелы
@export var speed = 4 # скорость стрелы
@export var shoot_sound_path = "" # путь до файла звука выстрела стрелы

var _target_act = null # актуальная цель стрелы
var _damage_multiplier = 1 # множитель урона

func _ready():
	look_at(_target_act.global_position)
	
func _physics_process(_delta):
	take_aim(_target_act)
	move_and_slide()

func take_aim(target):
	if target == null:
		return
	velocity = global_position.direction_to(target.global_position) * speed
	look_at(target.global_position)

func _on_area_2d_body_entered(body):
	if  body.is_in_group("goblins"):
		body.take_damage(damage * _damage_multiplier)
		queue_free()
		
func targeting(target, multiplier):
	_target_act = target
	_damage_multiplier = multiplier
