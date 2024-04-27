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

func show_build_popup(pos: Vector2i, reqires: Array[int]):
	# У Window, которым является BuildPopup нет возможности задать какой-либо AnchorPoint, поэтому приходится считать тут
	$BuildPopup.set_position(Vector2i(pos.x - $BuildPopup.get_size().x / 2, pos.y - $BuildPopup.get_size().y - 20))
	get_node("BuildPopup/Control/PanelContainer/GridContainer/WoodCount/WoodRequired").text = str(reqires[0]);
	get_node("BuildPopup/Control/PanelContainer/GridContainer/MeatCount/MeatRequired").text = str(reqires[1]);
	get_node("BuildPopup/Control/PanelContainer/GridContainer/GoldCount/GoldRequired").text = str(reqires[2]);
	$BuildPopup.show();


func _on_build_confirm():
	$BuildPopup.hide();
