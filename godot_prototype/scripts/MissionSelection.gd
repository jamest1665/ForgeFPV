# MissionSelection.gd — Academy mission list UI controller
extends Control

var list_box: VBoxContainer
var detail: Label
var selected_id: String = ""

func _ready() -> void:
	_build_ui()
	_populate()

func _build_ui() -> void:
	var bg := ColorRect.new()
	bg.color = Color(0.05, 0.06, 0.09)
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(bg)

	var title := Label.new()
	title.text = "Academy Missions"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 28)
	title.position = Vector2(100, 20)
	title.size = Vector2(1080, 40)
	add_child(title)

	var scroll := ScrollContainer.new()
	scroll.position = Vector2(40, 80)
	scroll.size = Vector2(560, 520)
	add_child(scroll)
	list_box = VBoxContainer.new()
	list_box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.add_child(list_box)

	detail = Label.new()
	detail.position = Vector2(640, 80)
	detail.size = Vector2(580, 400)
	detail.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	detail.add_theme_font_size_override("font_size", 16)
	detail.text = "Select a mission."
	add_child(detail)

	var btn_start := Button.new()
	btn_start.text = "Start Mission"
	btn_start.position = Vector2(640, 500)
	btn_start.size = Vector2(280, 50)
	btn_start.pressed.connect(_on_start)
	add_child(btn_start)

	var btn_back := Button.new()
	btn_back.text = "Back"
	btn_back.position = Vector2(940, 500)
	btn_back.size = Vector2(200, 50)
	btn_back.pressed.connect(func(): get_tree().change_scene_to_file("res://scenes/ui/MainMenu.tscn"))
	add_child(btn_back)

func _populate() -> void:
	var db: MissionDatabase = null
	if typeof(MissionManager) != TYPE_NIL and MissionManager.has_method("get_database"):
		db = MissionManager.get_database()
	else:
		db = MissionDatabase.new()
		db._register_defaults()
	for m in db.list_missions():
		var b := Button.new()
		b.text = "%s  [D%d]" % [m.title, m.difficulty]
		b.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		var mid: String = m.id
		b.pressed.connect(func(): _select(mid, m))
		list_box.add_child(b)

func _select(id: String, m: Mission) -> void:
	selected_id = id
	detail.text = "%s\n\n%s\n\nMap: %s\nTargets: %d\nTime limit: %s\n\n%s" % [
		m.title,
		m.description,
		m.map_id,
		m.target_count,
		("None" if m.time_limit_sec <= 0.0 else "%ds" % int(m.time_limit_sec)),
		m.briefing_notes
	]

func _on_start() -> void:
	if selected_id == "":
		return
	# Go through briefing scene with selected id stored on GameState-like path
	if typeof(MissionManager) != TYPE_NIL:
		MissionManager.set_meta("pending_mission_id", selected_id)
	get_tree().change_scene_to_file("res://scenes/ui/MissionBriefing.tscn")
