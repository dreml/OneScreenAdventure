class_name Dynamite
extends AnimatedSprite2D

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var initial_position = global_position

var target: Building
var damage := 10
var time_elapsed: float

func _ready():
	if global_position.x > target.global_position.x:
		animation_player.play('fly-left')
	else:
		animation_player.play('fly-right')

func _physics_process(delta):
	if not target:
		return

	var fly_target = target.foundation.global_position

	if global_position.distance_to(fly_target) < 5:
		explode()
		return

	global_position = lerp(initial_position, fly_target, time_elapsed)
	time_elapsed += delta

func explode():
	if animation_player.current_animation == 'explosion':
		return 

	target.take_damage(damage)
	animation_player.play('explosion')
	await animation_player.animation_finished
	queue_free()
