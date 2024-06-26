class_name Tower
extends Building

@onready var _attack_zone = $AttackZone/AttackZoneShape # зона атаки башни
@onready var reload_timer = $ReloadTimer # таймер перезарядки выстрела
@onready var _shoot_sound = $ShootSound
@onready var bomber_rally_point = $BomberRallyPoint

@export var _arrow_act: PackedScene = preload("res://objects/arrows/bare_arrow.tscn")
@export var _attack_speed : float = 1.5 # скорострельность
@export var _damage_multiplier : float = 2.0 # множитель урона снаряда

var _target_act = null # текущая цель
var _target_list : Array # массив целей

func _ready():
	super()
	
	reload_timer.set_wait_time(_attack_speed)
	get_shoot_sound(_arrow_act)
	
func attack_zone_update(proc):
	_attack_zone.scale *= (1+proc/100).round(2)
	
func attacking(target):
	if !is_constructed or target == null:
		return
		
	var shoot = _arrow_act.instantiate()
	_shoot_sound.play()
	shoot.targeting(target, _damage_multiplier)
	call_deferred("add_child", shoot)
	
	reload_timer.start()
	
func _on_reload_timer_timeout():
	attacking(_target_act)

func _on_attack_zone_body_entered(body):
	if !is_constructed():
		return

	if body.is_in_group("goblins"):
		_target_list.append(body)
		if _target_act == null:
			_target_act = _target_list[0]
		if reload_timer.is_stopped():
			attacking(_target_act)
	
func _on_attack_zone_body_exited(body):
	if body.is_in_group("goblins"):
		if _target_act == body:
			_target_list.pop_front()
			if len(_target_list) > 0:
				_target_act = _target_list[0]
			else:
				_target_act = null
		else:
			_target_list.erase(body)
		
func get_shoot_sound(_arrow):
	var shoot = _arrow_act.instantiate()
	_shoot_sound.stream = load(shoot.shoot_sound_path)
