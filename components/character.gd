class_name Character
extends CharacterBody2D

signal state_changed(new_state, prev_state)

@onready var movement_component: MovementComponent = $MovementComponent
@onready var health_component: HealthComponent = $HealthComponent
@onready var character_animation_component: CharacterAnimationComponent = $CharacterAnimationComponent

var prev_state = null
var state = null

func set_state(new_state):
	prev_state = state
	state = new_state
	
	character_animation_component.switch_animation()
	state_changed.emit(state, prev_state)

func get_state():
	return state
	
func get_prev_state():
	return prev_state
