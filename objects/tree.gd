extends Node2D

func _ready() -> void:
	await get_tree().create_timer(randf_range(0.0, 0.5)).timeout
	$AnimatedSprite2D.play('idle')

func _unhandled_input( event: InputEvent, ) -> void:
	if event.is_action_pressed('test'):
		$AnimatedSprite2D.play('chop')
		await ($AnimatedSprite2D.animation_finished)
		await get_tree().create_timer(randf_range(0.0, 0.3)).timeout
		$AnimatedSprite2D.play('idle')

func _on_Area2D_input_event(_viewport, _event, _shape_idx):
	pass

func _on_ClickableArea_input_event(_viewport, _event, _shape_idx):
	pass
