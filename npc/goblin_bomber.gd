class_name GoblinBomber
extends Goblin

@export var target_tower: Building

@onready var dynamite_prototype: PackedScene = preload("res://objects/dynamite.tscn")
@onready var throwing_point = $ThrowingPoint

func attacked():
	_change_target_action(TargetActions.RETURN_TO_PORTAL, home_camp.portal)
	await movement_component.arrived
	home_camp.handle_goblin_return_to_portal(self)

func _make_attack():
	if _attack_target == null or not _attack_target.has_method('take_damage'):
		return

	_change_state(States.ATTACK)

	# бросок через таймер, а не вызов функции из анимации, потому что годот не дает редактировать анимации родителей
	await get_tree().create_timer(0.2).timeout
	_throw_dynamite()
	
	await character_animation_component.animation_finished

	if state != States.ATTACK:
		return

	_change_state(OwnStates.PREPARE_ATTACK)
	attack_cd_timer.start()

func _start_attack_building():
	if not _target is Tower:
		return

	_attack_target = _target as Tower
	_attack_target.dead.connect(_handle_attack_target_dead)

	move_to(_target.bomber_rally_point.global_position)
	await movement_component.arrived

	_change_state(OwnStates.PREPARE_ATTACK)

func _throw_dynamite():
	var direction = sign(movement_component.facing_direction.x)

	var dynamite = dynamite_prototype.instantiate()
	dynamite.target = _attack_target
	dynamite.damage = attack_damage 
	var throwing_point_offset = Vector2(direction * throwing_point.position.x, throwing_point.position.y)
	dynamite.global_position = global_position + throwing_point_offset
	GameInstance.main.add_child(dynamite)
