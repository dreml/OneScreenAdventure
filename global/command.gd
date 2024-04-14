class_name Command

enum ActionType { Build }

var action_type: ActionType
var target: Node2D

func _init(_action_type: ActionType, _target: Node2D):
	self.action_type = _action_type
	self.target = _target
