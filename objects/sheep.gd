extends AnimatedSprite2D

func _process(_delta):
	if randi() % 1000 == 0:
		play('bounce')
		await animation_finished
		play('idle')
