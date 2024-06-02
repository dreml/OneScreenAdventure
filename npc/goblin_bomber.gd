class_name GoblinBomber
extends Goblin

@export var target_tower: Building
@export_file var dynamite: String

func _unhandled_key_input(event):
	if event.pressed and event.keycode == KEY_P:
		attack_building(target_tower)

func attacked():
	# продолжить атаковать здание или бежать обратно в портал?
	pass

func _make_attack():
	print("make_attack")
	# бросить динамит
	pass

func _start_attack_building():
	_change_state(OwnStates.PREPARE_ATTACK)
	# возможно, нужно создать точку у башни, в которую будут прибегать гоблины
	pass
