extends Npc

enum OwnStates { BUILD }

@export var productivity: int = 0

var _command_in_action: Command

func _ready() -> void:
	super._ready()

	ANIMATIONS_BY_STATES = Helpers.merge([
		ANIMATIONS_BY_STATES,
		{
			OwnStates.BUILD: "build"
		}
	])
	
	$MovementComponent.arrived.connect(_handle_arrival)
	
	print('hi from pawn')

func _process(delta):
	if _command_in_action == null && GameDirector.has_orders():
		_command_in_action = GameDirector.take_order()
		_start_command()

func _start_command():
	if _command_in_action.action_type == Command.ActionType.Build:
		movement_component.set_target_position(
			_command_in_action.target.get_entrance()
		)
		_switch_state(States.FOLLOW)

func _handle_arrival():
	if _command_in_action != null && _command_in_action.action_type == Command.ActionType.Build:
		_start_building()
		
func _start_building():
	_switch_state(OwnStates.BUILD)
	$Sprite2D.flip_h = movement_component.facing_direction.x < 0
	
	await _command_in_action.target.constructed
	_command_in_action = null
	_switch_state(States.IDLE)
	
func _build():
	if "build" in _command_in_action.target:
		_command_in_action.target.build(productivity)
