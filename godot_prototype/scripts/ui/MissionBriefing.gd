# MissionBriefing.gd — pre-flight brief then launch
extends Control

var mission: Mission

func _ready() -> void:
	var id := ""
	if typeof(MissionManager) != TYPE_NIL and MissionManager.has_meta("pending_mission_id"):
		id = str(MissionManager.get_meta("pending_mission_id"))
	if typeof(MissionManager) != TYPE_NIL:
		mission = MissionManager.get_database().get_mission(id)
	_build_ui()

func _build_ui() -> void:
	var bg := ColorRect.new()
	bg.color = Color(0.05, 0.06, 0.09)
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(bg)

	var title := Label.new()
	title.position = Vector2(100, 40)
	title.size = Vector2(1080, 50)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 28)
	title.text = mission.title if mission else "Mission Brief"
	add_child(title)

	var body := Label.new()
	body.position = Vector2(160, 120)
	body.size = Vector2(960, 360)
	body.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	body.add_theme_font_size_override("font_size", 18)
	if mission:
		body.text = "%s\n\nObjectives: Destroy %d targets.\n%s\n\nControls: WASD pitch/roll | Q/E yaw | Space/Ctrl throttle | ESC pause" % [
			mission.description,
			mission.target_count,
			mission.briefing_notes
		]
	else:
		body.text = "No mission selected."
	add_child(body)

	var btn_go := Button.new()
	btn_go.text = "Launch"
	btn_go.position = Vector2(440, 520)
	btn_go.size = Vector2(200, 50)
	btn_go.pressed.connect(_on_launch)
	add_child(btn_go)

	var btn_back := Button.new()
	btn_back.text = "Back"
	btn_back.position = Vector2(660, 520)
	btn_back.size = Vector2(200, 50)
	btn_back.pressed.connect(func(): get_tree().change_scene_to_file("res://scenes/ui/MissionSelection.tscn"))
	add_child(btn_back)

func _on_launch() -> void:
	if mission and typeof(MissionManager) != TYPE_NIL:
		MissionManager.start_mission(mission)
