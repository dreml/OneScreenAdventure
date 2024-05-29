extends CanvasLayer

@onready var build_popup = $BuildPopup
@onready var build_popup_animation = $BuildPopup/AnimationPlayer
@onready var wood_required = $BuildPopup/PanelContainer/VBoxContainer/GridContainer/WoodCount/WoodRequired
@onready var meat_required = $BuildPopup/PanelContainer/VBoxContainer/GridContainer/MeatCount/MeatRequired
@onready var gold_required = $BuildPopup/PanelContainer/VBoxContainer/GridContainer/GoldCount/GoldRequired
@onready var build_button = $BuildPopup/PanelContainer/VBoxContainer/Button

@export var grid: Node2D
@export var nav: NavigationMap
@export var level: TileMap

const POPUP_GAP := 20;
const HIDE_POPUP_POSITION := Vector2(-500, 0)

var current_building: Building = null;

func _ready():
	hide_build_popup()

func _on_toggle_debug_grid_button_pressed():
	grid.visible = !grid.visible

func show_build_popup(building: Building):
	var pos := building.get_position()
	var popupSize: Vector2 = build_popup.get_size()
	var viewportSize := get_viewport().get_visible_rect().size;

	var desirePosition := Vector2i(pos.x - popupSize.x * build_popup.scale.x / 2, pos.y - popupSize.y * build_popup.scale.y - POPUP_GAP);
	var clampedPosition := desirePosition.clamp(Vector2(POPUP_GAP, POPUP_GAP), viewportSize - Vector2(POPUP_GAP, POPUP_GAP) - popupSize);

	build_popup.set_position(clampedPosition);

	var is_enough_wood = GameInstance.wood_amount >= building.wood_requires
	var is_enough_meat = GameInstance.meat_amount >= building.meat_requires
	var is_enough_gold = GameInstance.gold_amount >= building.gold_requires

	if not is_enough_wood:
		wood_required.add_theme_color_override("default_color", Color(1, 0, 0))
	else:
		wood_required.remove_theme_color_override("default_color")

	if not is_enough_meat:
		meat_required.add_theme_color_override("default_color", Color(1, 0, 0))
	else:
		meat_required.remove_theme_color_override("default_color")

	if not is_enough_gold:
		gold_required.add_theme_color_override("default_color", Color(1, 0, 0))
	else:
		gold_required.remove_theme_color_override("default_color")

	wood_required.text = str(building.wood_requires)
	meat_required.text = str(building.meat_requires)
	gold_required.text = str(building.gold_requires)

	build_button.disabled = !building.can_be_built()
	current_building = building
	build_popup.show()
	build_popup_animation.play("open")

func hide_build_popup():
	build_popup_animation.play("close")
	await (build_popup_animation.animation_finished)
	build_popup.hide()
	build_popup.set_position(HIDE_POPUP_POSITION)
	
func is_popup_hidden():
	return not build_popup.visible

func _on_build_confirm():
	if current_building != null && current_building.start_building():
		GameInstance.game_director.create_order(
			Command.new(Command.ActionType.Build, current_building)
		)
	hide_build_popup()

func _input(event):
	if build_popup.visible and (event is InputEventMouseButton) and event.pressed:
		if !Rect2(build_popup.position, build_popup.get_size() * build_popup.scale).has_point(event.position):
			hide_build_popup()

