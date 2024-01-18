extends CanvasLayer

@export var grid: Node2D

func _on_button_pressed():
	grid.visible = !grid.visible
