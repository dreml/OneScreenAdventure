extends CanvasLayer

@onready var build_popup = $BuildPopup
@onready var wood_required = $BuildPopup/Control/PanelContainer/GridContainer/WoodCount/WoodRequired
@onready var meat_required = $BuildPopup/Control/PanelContainer/GridContainer/MeatCount/MeatRequired
@onready var gold_required = $BuildPopup/Control/PanelContainer/GridContainer/GoldCount/GoldRequired

@export var grid: Node2D
@export var nav: NavigationMap
@export var level: TileMap

var current_building: Building = null;

func _on_toggle_debug_grid_button_pressed():
	grid.visible = !grid.visible

func _on_build_bridge_button_pressed():
	nav.buid_bridge()
	level.build_bridge()
	$BuildBridgeButton.hide()

func _unhandled_input(_event: InputEvent) -> void:
	if Input.is_key_pressed(KEY_B):
		_on_build_bridge_button_pressed()

func show_build_popup(building: Building):
	# У Window, которым является BuildPopup нет возможности задать какой-либо AnchorPoint, поэтому приходится считать тут
	var pos = building.get_position()
	var popupSize = build_popup.get_size()
	build_popup.set_position(Vector2i(pos.x - popupSize.x / 2, pos.y - popupSize.y - 20))
	wood_required.text = str(building.wood_requires);
	meat_required.text = str(building.meat_requires);
	gold_required.text = str(building.gold_requires);
	current_building = building;
	build_popup.show();

func _on_build_confirm():
	if current_building != null && current_building.start_building():
		GameInstance.game_director.create_order(
			Command.new(Command.ActionType.Build, current_building)
		)
	build_popup.hide();
