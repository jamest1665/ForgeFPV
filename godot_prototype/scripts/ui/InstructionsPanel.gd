# InstructionsPanel.gd — first-run / Academy tips screen
extends Control
class_name InstructionsPanel

signal closed

func _ready() -> void:
	_build()

func _build() -> void:
	var bg := ColorRect.new()
	bg.color = Color(0.05, 0.06, 0.09)
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(bg)

	var title := Label.new()
	title.text = "ForgeFPV — Pilot Brief"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 28)
	title.position = Vector2(100, 30)
	title.size = Vector2(1080, 40)
	add_child(title)

	var body := Label.new()
	body.position = Vector2(120, 90)
	body.size = Vector2(1040, 420)
	body.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	body.add_theme_font_size_override("font_size", 17)
	body.text = "Welcome to the American FPV tactical trainer.\n\n" + \
		"1. Select an airframe under Select Airframe (optional — default Trainer 5-inch).\n" + \
		"2. Free-fly any map from the main menu, or run Academy Missions for structured drills.\n" + \
		"3. Rate-mode flight: W/S pitch, A/D roll, Q/E yaw, Space/Ctrl throttle.\n" + \
		"4. Red targets score on proximity. ESC pauses. H shows in-flight help.\n" + \
		"5. Aquatic maps use water buoyancy and current — stay above the surface.\n\n" + \
		"Tip: Start on Donbas Field, then Urban Canyon for tighter corridors."
	add_child(body)

	var btn := Button.new()
	btn.text = "Got it"
	btn.position = Vector2(540, 560)
	btn.size = Vector2(200, 48)
	btn.pressed.connect(_on_close)
	add_child(btn)

func _on_close() -> void:
	closed.emit()
	if get_tree().current_scene == self or get_parent() == null:
		get_tree().change_scene_to_file("res://scenes/ui/MainMenu.tscn")
	else:
		queue_free()
