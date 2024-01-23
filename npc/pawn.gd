extends Npc

@export var build: bool

func _ready() -> void:
	super._ready()
	
	print('hi from pawn')
	
	if build:
		$AnimatedSprite2D.play('build')
	
