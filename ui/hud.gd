extends CanvasLayer

@export var grid: Node2D
@export var nav: NavigationMap

func _on_toggle_debug_grid_button_pressed():
	grid.visible = !grid.visible

func _on_build_bridge_button_pressed():
	nav.buid_bridge()
