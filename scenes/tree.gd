extends Node2D


func _on_Area2D_input_event(viewport, event, shape_idx):
	if event.is_action_pressed('click'):
		print('asdf')


func _on_ClickableArea_input_event(viewport, event, shape_idx):
	pass # Replace with function body.
