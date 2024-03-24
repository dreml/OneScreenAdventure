class_name Npc
extends CharacterBody2D

# такие числа, чтобы потомки легко могли задавать свои состояния
enum States { IDLE = 100, FOLLOW = 101, ATTACK = 102 }

var ANIMATIONS_BY_STATES: Dictionary = {
	States.IDLE: 'idle',
	States.FOLLOW: 'run',
	States.ATTACK: 'attack',
}

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var movement_component: MovementComponent = $MovementComponent

var state := States.IDLE
var prev_state = null

# TODO сделать поворот спрайта в движении

func _ready() -> void:
	movement_component.arrived.connect(func(): _switch_state(States.IDLE))

func _switch_state(new_state):
	prev_state = state
	state = new_state
	
	movement_component.can_move = state == States.FOLLOW
	
	if ANIMATIONS_BY_STATES.has(state):
		animation_player.play(ANIMATIONS_BY_STATES[state])
		
	_handle_switch_state()

func _handle_switch_state():
	pass
