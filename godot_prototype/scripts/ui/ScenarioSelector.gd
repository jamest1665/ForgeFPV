# ScenarioSelector.gd — pick scenario flavor for free-play or briefing context
extends Control

var selected_id: String = "target_practice"
var detail: Label

const SCENARIOS := [
	{"id": "target_practice", "name": "Target Practice", "desc": "Standard target clearing. Score x1.0"},
	{"id": "timed_strike", "name": "Timed Strike", "desc": "Clock pressure. Score x1.25"},
	{"id": "flanking", "name": "Flanking Drill", "desc": "Off-axis approaches. Score x1.5, wind x1.1"},
	{"id": "ring_defense", "name": "Ring Defense", "desc": "Hold space / clear ring. Score x1.35, wind x1.2"},
]

func _ready() -> void:
	if typeof(GameState) != TYPE_NIL and GameState.has_meta("selected_scenario"):
		selected_id = str(GameState.get_meta("selected_scenario"))
	_build_ui()

func _build_ui() -> void:
	var bg := ColorRect.new()
	bg.color = Color(0.05, 0.06, 0.09)
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(bg)

	var title := Label.new()
	title.text = "Scenario Type"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 28)
	title.position = Vector2(100, 24)
	title.size = Vector2(1080, 40)
	add_child(title)

	var y := 100.0
	for s in SCENARIOS:
		var b := Button.new()
		b.text = s["name"]
		b.position = Vector2(200, y)
		b.size = Vector2(400, 44)
		var sid: String = s["id"]
		b.pressed.connect(func(): _select(sid))
		add_child(b)
		y += 56.0

	detail = Label.new()
	detail.position = Vector2(640, 100)
	detail.size = Vector2(500, 300)
	detail.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	detail.add_theme_font_size_override("font_size", 16)
	add_child(detail)
	_select(selected_id)

	var btn_ok := Button.new()
	btn_ok.text = "Confirm"
	btn_ok.position = Vector2(440, 560)
	btn_ok.size = Vector2(200, 48)
	btn_ok.pressed.connect(_on_confirm)
	add_child(btn_ok)

	var btn_back := Button.new()
	btn_back.text = "Back"
	btn_back.position = Vector2(660, 560)
	btn_back.size = Vector2(200, 48)
	btn_back.pressed.connect(func(): get_tree().change_scene_to_file("res://scenes/ui/MainMenu.tscn"))
	add_child(btn_back)

func _select(id: String) -> void:
	selected_id = id
	for s in SCENARIOS:
		if s["id"] == id:
			detail.text = "%s\n\n%s" % [s["name"], s["desc"]]
			return
	detail.text = id

func _on_confirm() -> void:
	if typeof(GameState) != TYPE_NIL:
		GameState.set_meta("selected_scenario", selected_id)
	if typeof(MissionManager) != TYPE_NIL and MissionManager.scenario:
		MissionManager.scenario.apply_scenario(selected_id)
	get_tree().change_scene_to_file("res://scenes/ui/MainMenu.tscn")
