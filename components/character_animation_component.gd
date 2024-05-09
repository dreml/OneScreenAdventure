class_name CharacterAnimationComponent
extends AnimationTree

const AT_STATE_MACHINE := "parameters/StateMachine/playback"
const AT_BLEND_POSITION_PATH := "parameters/StateMachine/%s/blend_position"

var parent: Character
var animations_by_states = {}

func _ready():
	parent = owner
	update_animation_direction()

func set_animations(dict: Dictionary):
	animations_by_states = dict

func switch_animation():
	if !animations_by_states.has(parent.state):
		return

	var state_machine = get(AT_STATE_MACHINE)
	state_machine.travel(_get_animation_name_by_state())

func update_animation_direction():
	for key in animations_by_states:
		var animation_name = animations_by_states[key]
		self[AT_BLEND_POSITION_PATH % animation_name] = parent.movement_component.facing_direction.x

func _get_animation_name_by_state():
	return animations_by_states[parent.state]
