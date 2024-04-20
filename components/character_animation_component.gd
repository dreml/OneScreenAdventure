class_name CharacterAnimationComponent
extends AnimationTree

const AT_CONDITION_PATH := "parameters/StateMachine/conditions/%s"
const AT_BLEND_POSITION_PATH := "parameters/StateMachine/%s/blend_position"

var parent: Character
var animations_by_states = {}

func _ready():
	parent = owner

func _physics_process(delta):
	_update_animation_direction()

func set_animations(dict: Dictionary):
	animations_by_states = dict

func switch_animation():
	if !animations_by_states.has(parent.get_state()):
		return

	for state in animations_by_states:
		var animation_name = animations_by_states[state]
		set(AT_CONDITION_PATH % animation_name, state == parent.get_state())

func _update_animation_direction():
	var animation_name = animations_by_states[parent.get_state()]

	set(
		AT_BLEND_POSITION_PATH % animation_name,
		parent.movement_component.facing_direction.x
	)
