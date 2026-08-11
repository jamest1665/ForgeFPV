extends Control

func _ready() -> void:
	_build_ui()

func _build_ui() -> void:
	var bg := ColorRect.new()
	bg.color = Color(0.05, 0.06, 0.09)
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(bg)

	var summary: Dictionary = {}
	if typeof(MissionManager) != TYPE_NIL:
		summary = MissionManager.last_summary

	var success := bool(summary.get("success", false))
	var title := Label.new()
	title.position = Vector2(100, 40)
	title.size = Vector2(1080, 50)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 30)
	title.text = "MISSION COMPLETE" if success else "MISSION FAILED"
	add_child(title)

	var body := Label.new()
	body.position = Vector2(200, 120)
	body.size = Vector2(880, 200)
	body.add_theme_font_size_override("font_size", 20)
	body.text = "%s\n\nScore: %d\nTargets: %d / %d\nTime: %.1fs\nPeak speed: %.1f m/s\n%s" % [
		str(summary.get("title", "")),
		int(summary.get("score", 0)),
		int(summary.get("hits", 0)),
		int(summary.get("total_targets", 0)),
		float(summary.get("time_sec", 0.0)),
		float(summary.get("peak_speed", 0.0)),
		str(summary.get("fail_reason", ""))
	]
	add_child(body)

	var panel := DebriefPanel.new()
	panel.position = Vector2(200, 360)
	add_child(panel)
	panel.show_summary(summary)

	var btn_again := Button.new()
	btn_again.text = "Missions"
	btn_again.position = Vector2(400, 560)
	btn_again.size = Vector2(200, 48)
	btn_again.pressed.connect(func(): get_tree().change_scene_to_file("res://scenes/ui/MissionSelection.tscn"))
	add_child(btn_again)

	var btn_menu := Button.new()
	btn_menu.text = "Main Menu"
	btn_menu.position = Vector2(640, 560)
	btn_menu.size = Vector2(200, 48)
	btn_menu.pressed.connect(func(): get_tree().change_scene_to_file("res://scenes/ui/MainMenu.tscn"))
	add_child(btn_menu)
