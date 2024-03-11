class_name Npc
extends CharacterBody2D

enum States { IDLE, FOLLOW, ATTACK }

const ANIMATIONS_BY_STATES: Dictionary = {
    States.IDLE: 'idle',
    States.FOLLOW: 'run',
    States.ATTACK: 'attack',
}

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var movement_component: MovementComponent = $MovementComponent

var state := States.IDLE

# TODO сделать поворот спрайта в движении

func _ready() -> void:
    movement_component.arrived.connect(func(): _switch_state(States.IDLE))

func _switch_state(new_state):
    state = new_state
    
    movement_component.can_move = state == States.FOLLOW
    
    if ANIMATIONS_BY_STATES.has(state):
        sprite.play(ANIMATIONS_BY_STATES[state])