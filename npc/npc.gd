class_name Npc
extends CharacterBody2D

signal dead

# такие числа, чтобы потомки легко могли задавать свои состояния
enum States { IDLE = 100, FOLLOW = 101, ATTACK = 102 }

var ANIMATIONS_BY_STATES: Dictionary = {
	States.IDLE: 'idle',
	States.FOLLOW: 'run',
	States.ATTACK: 'attack',
}

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var movement_component: MovementComponent = $MovementComponent
@onready var health_component: HealthComponent = $HealthComponent

var state := States.IDLE
var prev_state = null

# TODO сделать поворот спрайта в движении

func _ready() -> void:
	movement_component.arrived.connect(func(): _switch_state(States.IDLE))
	health_component.dead.connect(
		func():
			queue_free()
			dead.emit()
	)

func _switch_state(new_state):
	prev_state = state
	state = new_state
	
	movement_component.can_move = state == States.FOLLOW
	
	if ANIMATIONS_BY_STATES.has(state):
		animation_player.play(ANIMATIONS_BY_STATES[state])

func take_damage(damage_amount: int):
	health_component.take_damage(damage_amount)
