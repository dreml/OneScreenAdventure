class_name HealthComponent
extends Component

signal health_changed(current_health: int)
signal full_health
signal dead

@export var max_health: int = 5
@export var start_with_zero_health := false

var _current_health: int

func _ready():
	_current_health = 0 if start_with_zero_health else max_health

func add_health(amount: int):
	if amount <= 0:
		return

	_current_health = min(_current_health + amount, max_health)

	if _current_health == max_health:
		full_health.emit()

	health_changed.emit(_current_health)
	print(owner.name + ' health: ' + str(_current_health ))

func take_damage(amount: int):
	if amount <= 0:
		return

	_current_health = max(0, _current_health - amount)

	if _current_health == 0:
		print(owner.name + ' is dead')
		dead.emit()

	health_changed.emit(_current_health)
	print(owner.name + ' health: ' + str(_current_health ))
