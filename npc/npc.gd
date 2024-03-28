class_name Npc
extends CharacterBody2D

enum States { IDLE, FOLLOW, ATTACK }

const ANIMATIONS_BY_STATES: Dictionary = {
	States.IDLE: 'idle',
	States.FOLLOW: 'run',
}

signal dead

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var movement_component: MovementComponent = $MovementComponent
@onready var health_component: HealthComponent = $HealthComponent

var _state := States.IDLE

# TODO сделать поворот спрайта в движении

func _ready() -> void:
	movement_component.arrived.connect(func(): _change_state(States.IDLE))
	health_component.dead.connect(
		func():
			queue_free()
			dead.emit()
	)

func _change_state(new_state: States):
	if _state == new_state:
		return
	
	_state = new_state
	movement_component.can_move = _state == States.FOLLOW
	
	if ANIMATIONS_BY_STATES.has(_state):
		sprite.play(ANIMATIONS_BY_STATES[_state])

func take_damage(damage_amount: int):
	health_component.take_damage(damage_amount)
