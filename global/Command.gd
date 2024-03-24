class_name Command

enum ActionType {Build}

var action_type: ActionType
var target: Node2D

func _init(action_type: ActionType, target: Node2D):
	self.action_type = action_type
	self.target = target
