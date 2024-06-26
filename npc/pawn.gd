extends Npc

enum OwnStates { BUILD }

@export var productivity: int = 0

@onready var sprite: Sprite2D = $Sprite2D

var _command_in_action: Command

func _ready() -> void:
	ANIMATIONS_BY_STATES = Helpers.merge([
		ANIMATIONS_BY_STATES,
		{
			OwnStates.BUILD: "build"
		}
	])
	
	super._ready()
	
	movement_component.arrived.connect(_handle_arrival)

func _process(_delta):
	if _command_in_action == null && GameInstance.game_director.has_orders():
		_command_in_action = GameInstance.game_director.take_order()
		_start_command()

func _start_command():
	if _command_in_action.action_type == Command.ActionType.Build:
		movement_component.set_target_position(
			_command_in_action.target.get_entrance()
		)
		_change_state(States.FOLLOW)

func _handle_arrival():
	if _command_in_action != null && _command_in_action.action_type == Command.ActionType.Build:
		_start_building()
		
func _start_building():
	_change_state(OwnStates.BUILD)
	
	await _command_in_action.target.constructed
	queue_free()
	
func _build():
	if "build" in _command_in_action.target:
		_command_in_action.target.build(productivity)
