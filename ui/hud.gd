extends CanvasLayer

@export var grid: Node2D
@export var nav: NavigationMap
@export var level: TileMap

func _on_toggle_debug_grid_button_pressed():
	grid.visible = !grid.visible

func _on_build_bridge_button_pressed():
	nav.buid_bridge()
	level.build_bridge()
	$BuildBridgeButton.hide()

func _unhandled_input(_event: InputEvent) -> void:
	if Input.is_key_pressed(KEY_B):
		_on_build_bridge_button_pressed()
