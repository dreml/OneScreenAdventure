class_name BuildPopup
extends Control

@onready var animation_player = $AnimationPlayer

@onready var wood_required = %WoodRequiredLabel
@onready var meat_required = %MeatRequiredLabel
@onready var gold_required = %GoldRequiredLabel
@onready var build_button = %BuildButton

const POPUP_GAP := 20;
const HIDE_POPUP_POSITION := Vector2(-500, 0)

var current_building: Building = null;

func show_popup(building: Building):
	var building_position := building.get_position()
	var popup_size: Vector2 = get_size()
	var viewport_size := get_viewport().get_visible_rect().size;

	var desire_position := Vector2(building_position.x - popup_size.x * scale.x / 2, building_position.y - popup_size.y * scale.y - POPUP_GAP);
	var clamped_position := desire_position.clamp(Vector2(POPUP_GAP, POPUP_GAP), viewport_size - Vector2(POPUP_GAP, POPUP_GAP) - popup_size);

	position = clamped_position

	var is_enough_wood = GameInstance.wood_amount >= building.wood_requires
	var is_enough_meat = GameInstance.meat_amount >= building.meat_requires
	var is_enough_gold = GameInstance.gold_amount >= building.gold_requires

	if not is_enough_wood:
		wood_required.add_theme_color_override('default_color', Color(1, 0, 0))
	else:
		wood_required.remove_theme_color_override('default_color')

	if not is_enough_meat:
		meat_required.add_theme_color_override('default_color', Color(1, 0, 0))
	else:
		meat_required.remove_theme_color_override('default_color')

	if not is_enough_gold:
		gold_required.add_theme_color_override('default_color', Color(1, 0, 0))
	else:
		gold_required.remove_theme_color_override('default_color')

	wood_required.text = str(building.wood_requires)
	meat_required.text = str(building.meat_requires)
	gold_required.text = str(building.gold_requires)

	build_button.disabled = !building.can_be_built()
	current_building = building
	show()
	animation_player.play('open')

func hide_popup():
	animation_player.play('close')
	await (animation_player.animation_finished)
	hide()
	position = HIDE_POPUP_POSITION
	
func is_popup_hidden():
	return not visible

func _on_build_button_pressed():
	if current_building != null && current_building.start_building():
		GameInstance.game_director.create_order(
			Command.new(Command.ActionType.Build, current_building)
		)
	hide_popup()
