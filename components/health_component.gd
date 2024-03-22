class_name HealthComponent
extends Component

signal health_changed(current_health: int)
signal dead

@export var max_health: int = 5

var _current_health := max_health

func take_damage(damage_amount: int):
	if damage_amount <= 0:
		return

	_current_health = max(0, _current_health - damage_amount)

	if _current_health == 0:
		print(owner.name + ' is dead')
		dead.emit()

	health_changed.emit(_current_health)
	print(owner.name + ' health: ' + str(_current_health ))
