# SettingsMenu.gd — Phase 1 pilot settings (rates, expo, invert, FOV, gamepad)
extends Control

var labels: Dictionary = {}

func _ready() -> void:
	_build()

func _build() -> void:
	var bg := ColorRect.new()
	bg.color = Color(0.05, 0.06, 0.09)
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(bg)

	var title := Label.new()
	title.text = "Pilot Settings  ·  ForgeFPV %s" % _version()
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 24)
	title.position = Vector2(100, 16)
	title.size = Vector2(1080, 36)
	add_child(title)

	var y := 70.0
	y = _add_slider("rate_pitch", "Pitch rate", 0.4, 2.0, PilotSettings.rate_pitch, y)
	y = _add_slider("rate_roll", "Roll rate", 0.4, 2.0, PilotSettings.rate_roll, y)
	y = _add_slider("rate_yaw", "Yaw rate", 0.4, 2.0, PilotSettings.rate_yaw, y)
	y = _add_slider("expo", "Expo", 0.0, 0.9, PilotSettings.expo, y)
	y = _add_slider("deadzone", "Deadzone", 0.0, 0.25, PilotSettings.deadzone, y)
	y = _add_slider("fov", "FPV FOV", 80.0, 120.0, PilotSettings.fov, y)
	y = _add_toggle("invert_pitch", "Invert pitch", PilotSettings.invert_pitch, y)
	y = _add_toggle("invert_roll", "Invert roll", PilotSettings.invert_roll, y)
	y = _add_toggle("invert_yaw", "Invert yaw", PilotSettings.invert_yaw, y)
	y = _add_toggle("invert_throttle", "Invert throttle", PilotSettings.invert_throttle, y)
	y = _add_toggle("use_gamepad", "Use gamepad / RC (joy0)", PilotSettings.use_gamepad, y)

	var hint := Label.new()
	hint.position = Vector2(120, y + 10)
	hint.size = Vector2(1000, 60)
	hint.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	hint.text = "Gamepad: left stick pitch/roll · right stick X yaw · right stick Y or triggers throttle. Keyboard still works. Dynamics (step) unchanged."
	add_child(hint)

	var btn_save := Button.new()
	btn_save.text = "Save"
	btn_save.position = Vector2(440, 620)
	btn_save.size = Vector2(160, 44)
	btn_save.pressed.connect(_on_save)
	add_child(btn_save)

	var btn_back := Button.new()
	btn_back.text = "Back"
	btn_back.position = Vector2(620, 620)
	btn_back.size = Vector2(160, 44)
	btn_back.pressed.connect(func(): get_tree().change_scene_to_file("res://scenes/ui/MainMenu.tscn"))
	add_child(btn_back)

func _version() -> String:
	return str(ProjectSettings.get_setting("application/config/version", "0.2.0"))

func _add_slider(key: String, caption: String, mn: float, mx: float, val: float, y: float) -> float:
	var lab := Label.new()
	lab.position = Vector2(120, y)
	lab.size = Vector2(280, 28)
	lab.text = "%s: %.2f" % [caption, val]
	add_child(lab)
	labels[key] = lab
	var sl := HSlider.new()
	sl.min_value = mn
	sl.max_value = mx
	sl.step = 0.01
	sl.value = val
	sl.position = Vector2(420, y)
	sl.size = Vector2(480, 28)
	sl.value_changed.connect(func(v): _on_slider(key, v, caption))
	add_child(sl)
	return y + 42.0

func _add_toggle(key: String, caption: String, val: bool, y: float) -> float:
	var cb := CheckButton.new()
	cb.text = caption
	cb.button_pressed = val
	cb.position = Vector2(120, y)
	cb.size = Vector2(500, 32)
	cb.toggled.connect(func(on): _on_toggle(key, on))
	add_child(cb)
	return y + 40.0

func _on_slider(key: String, v: float, caption: String) -> void:
	match key:
		"rate_pitch":
			PilotSettings.rate_pitch = v
		"rate_roll":
			PilotSettings.rate_roll = v
		"rate_yaw":
			PilotSettings.rate_yaw = v
		"expo":
			PilotSettings.expo = v
		"deadzone":
			PilotSettings.deadzone = v
		"fov":
			PilotSettings.fov = v
	if labels.has(key):
		labels[key].text = "%s: %.2f" % [caption, v]

func _on_toggle(key: String, on: bool) -> void:
	match key:
		"invert_pitch":
			PilotSettings.invert_pitch = on
		"invert_roll":
			PilotSettings.invert_roll = on
		"invert_yaw":
			PilotSettings.invert_yaw = on
		"invert_throttle":
			PilotSettings.invert_throttle = on
		"use_gamepad":
			PilotSettings.use_gamepad = on

func _on_save() -> void:
	PilotSettings.save_settings()
	print("PilotSettings saved")
