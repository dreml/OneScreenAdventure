extends CanvasLayer

@onready var gold_label: Label = %GoldResource/Label
@onready var wood_label: Label = %WoodResource/Label
@onready var meat_label: Label = %MeatResource/Label

@onready var build_popup: BuildPopup = $BuildPopup

@onready var animation_player: AnimationPlayer = $AnimationPlayer

@export var grid: Node2D
@export var nav: NavigationMap
@export var level: TileMap

var current_building: Building = null;
var _settings_hidden := true

func _ready():
	build_popup.hide_popup()

func _process(_delta):
	gold_label.set_text(str(GameInstance.gold_amount))
	wood_label.set_text(str(GameInstance.wood_amount))
	meat_label.set_text(str(GameInstance.meat_amount))

func _on_toggle_debug_grid_button_pressed():
	grid.visible = !grid.visible

func _input(event):
	if build_popup.visible and (event is InputEventMouseButton) and event.pressed:
		if !Rect2(build_popup.position, build_popup.get_size() * build_popup.scale).has_point(event.position):
			build_popup.hide_popup()

func is_build_popup_hidden():
	return not build_popup.visible

func show_build_popup(building: Building):
	build_popup.show_popup(building)

func hide_build_popup():
	build_popup.hide_popup()

func _on_settings_button_pressed():
	if _settings_hidden:
		animation_player.play("show_settings")
	else:
		animation_player.play_backwards("show_settings")

	_settings_hidden = not _settings_hidden

func _on_mute_button_pressed():
	var _sound = AudioServer.get_bus_index("Master")
	AudioServer.set_bus_mute(_sound, not AudioServer.is_bus_mute(_sound))
