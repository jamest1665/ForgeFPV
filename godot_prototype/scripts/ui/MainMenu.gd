# MainMenu.gd
# Production Main Menu - explicit layout so UI is always visible

extends Control

@export var donbas_scene_path: String = "res://scenes/maps/DonbasTest.tscn"
@export var urban_scene_path: String = "res://scenes/maps/UrbanTest.tscn"

var selected_teams: int = 2
var selected_drones_per_team: int = 8
var selected_scenario: String = "ring_defense"

var start_button: Button
var urban_button: Button
var quit_button: Button
var scenario_button: Button
var team_label: Label
var drone_label: Label
var title_label: Label

func _ready():
	set_anchors_preset(Control.PRESET_FULL_RECT)
	_build_ui()
	_wire_buttons()
	print("MainMenu: Ready")

func _build_ui():
	var bg = ColorRect.new()
	bg.name = "Background"
	bg.color = Color(0.07, 0.08, 0.11, 1)
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(bg)
	move_child(bg, 0)

	title_label = Label.new()
	title_label.name = "TitleLabel"
	title_label.text = "ForgeFPV — Tactical Drone Trainer"
	title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title_label.set_anchors_preset(Control.PRESET_TOP_WIDE)
	title_label.offset_top = 40
	title_label.offset_bottom = 80
	title_label.add_theme_font_size_override("font_size", 28)
	add_child(title_label)

	var subtitle = Label.new()
	subtitle.text = "American FPV Training Simulator"
	subtitle.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	subtitle.set_anchors_preset(Control.PRESET_TOP_WIDE)
	subtitle.offset_top = 85
	subtitle.offset_bottom = 115
	add_child(subtitle)

	start_button = _make_button("StartButton", "Start Donbas Training", 0)
	urban_button = _make_button("UrbanButton", "Start Urban Training", 1)
	scenario_button = _make_button("ScenarioButton", "Scenario: Ring Defense", 2)
	quit_button = _make_button("QuitButton", "Quit", 5)

	team_label = Label.new()
	team_label.name = "TeamLabel"
	team_label.text = "Teams: 2  |  Drones/Team: 8"
	team_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	team_label.set_anchors_preset(Control.PRESET_CENTER)
	team_label.position = Vector2(-150, 90)
	team_label.size = Vector2(300, 30)
	add_child(team_label)

	drone_label = Label.new()
	drone_label.name = "HintLabel"
	drone_label.text = "Click a map button to begin training"
	drone_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	drone_label.set_anchors_preset(Control.PRESET_CENTER)
	drone_label.position = Vector2(-180, 130)
	drone_label.size = Vector2(360, 30)
	add_child(drone_label)

func _make_button(node_name: String, text: String, index: int) -> Button:
	var b = Button.new()
	b.name = node_name
	b.text = text
	b.custom_minimum_size = Vector2(280, 44)
	b.set_anchors_preset(Control.PRESET_CENTER)
	b.position = Vector2(-140, -40 + index * 55)
	b.size = Vector2(280, 44)
	add_child(b)
	return b

func _wire_buttons():
	if start_button:
		start_button.pressed.connect(_on_start_donbas)
	if urban_button:
		urban_button.pressed.connect(_on_start_urban)
	if scenario_button:
		scenario_button.pressed.connect(_on_scenario_pressed)
	if quit_button:
		quit_button.pressed.connect(func(): get_tree().quit())

func _on_scenario_pressed():
	match selected_scenario:
		"ring_defense":
			selected_scenario = "flanking_attack"
			scenario_button.text = "Scenario: Flanking Attack"
		"flanking_attack":
			selected_scenario = "inspection_orbit"
			scenario_button.text = "Scenario: Inspection Orbit"
		_:
			selected_scenario = "ring_defense"
			scenario_button.text = "Scenario: Ring Defense"

func _on_start_donbas():
	_start_game(donbas_scene_path)

func _on_start_urban():
	_start_game(urban_scene_path)

func _start_game(scene_path: String):
	if has_node("/root/GameState"):
		var gs = get_node("/root/GameState")
		if gs.has_method("set_team_selection"):
			gs.set_team_selection(selected_teams, selected_drones_per_team)
		if gs.has_method("set_scenario"):
			gs.set_scenario(selected_scenario)
		gs.set("selected_teams", selected_teams)
		gs.set("selected_drones_per_team", selected_drones_per_team)
		gs.set("selected_scenario", selected_scenario)

	print("MainMenu: Loading ", scene_path)
	var err = get_tree().change_scene_to_file(scene_path)
	if err != OK:
		push_error("MainMenu: Failed to load scene %s (error %s)" % [scene_path, str(err)])
