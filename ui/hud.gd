extends CanvasLayer

@onready var build_popup = $BuildPopup
@onready var wood_required = $BuildPopup/Control/PanelContainer/GridContainer/WoodCount/WoodRequired
@onready var meat_required = $BuildPopup/Control/PanelContainer/GridContainer/MeatCount/MeatRequired
@onready var gold_required = $BuildPopup/Control/PanelContainer/GridContainer/GoldCount/GoldRequired
@onready var build_button = $BuildPopup/Control/PanelContainer/Button

@export var grid: Node2D
@export var nav: NavigationMap
@export var level: TileMap

const POPUP_GAP := 20;

var current_building: Building = null;

func _on_toggle_debug_grid_button_pressed():
	grid.visible = !grid.visible

func show_build_popup(building: Building):
	# У Window, которым является BuildPopup нет возможности задать какой-либо AnchorPoint, поэтому приходится считать тут
	# так же отдельно клэмпим позицию чтобы попап оставался всегда в пределах экрана
	var pos := building.get_position()
	var popupSize: Vector2 = build_popup.get_size()
	var viewportSize := get_viewport().get_visible_rect().size;

	var desirePosition := Vector2i(pos.x - popupSize.x / 2, pos.y - popupSize.y - POPUP_GAP);
	var clampedPosition := desirePosition.clamp(Vector2(POPUP_GAP, POPUP_GAP), viewportSize - Vector2(POPUP_GAP, POPUP_GAP) - popupSize);

	build_popup.set_position(clampedPosition);
	
	wood_required.text = str(building.wood_requires);
	meat_required.text = str(building.meat_requires);
	gold_required.text = str(building.gold_requires);
	build_button.disabled = !building.can_be_built();
	current_building = building;
	build_popup.show();

func _on_build_confirm():
	if current_building != null && current_building.start_building():
		GameInstance.game_director.create_order(
			Command.new(Command.ActionType.Build, current_building)
		)
	build_popup.hide();
