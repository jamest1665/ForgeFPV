# DroneSelection.gd — pick airframe; stores id on GameState
extends Control

var list_box: VBoxContainer
var detail: Label
var selected_id: String = "trainer_5inch"
var db: DroneDatabase

func _ready() -> void:
	db = DroneDatabase.new()
	db._register_defaults()
	if typeof(GameState) != TYPE_NIL:
		selected_id = GameState.selected_drone
	_build_ui()
	_populate()
	_show_detail(selected_id)

func _build_ui() -> void:
	var bg := ColorRect.new()
	bg.color = Color(0.05, 0.06, 0.09)
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(bg)

	var title := Label.new()
	title.text = "Select Airframe"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 28)
	title.position = Vector2(100, 20)
	title.size = Vector2(1080, 40)
	add_child(title)

	var scroll := ScrollContainer.new()
	scroll.position = Vector2(40, 80)
	scroll.size = Vector2(520, 500)
	add_child(scroll)
	list_box = VBoxContainer.new()
	list_box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.add_child(list_box)

	detail = Label.new()
	detail.position = Vector2(600, 80)
	detail.size = Vector2(620, 400)
	detail.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	detail.add_theme_font_size_override("font_size", 16)
	add_child(detail)

	var btn_confirm := Button.new()
	btn_confirm.text = "Confirm Airframe"
	btn_confirm.position = Vector2(600, 520)
	btn_confirm.size = Vector2(280, 50)
	btn_confirm.pressed.connect(_on_confirm)
	add_child(btn_confirm)

	var btn_back := Button.new()
	btn_back.text = "Back"
	btn_back.position = Vector2(900, 520)
	btn_back.size = Vector2(200, 50)
	btn_back.pressed.connect(func(): get_tree().change_scene_to_file("res://scenes/ui/MainMenu.tscn"))
	add_child(btn_back)

func _populate() -> void:
	for id in db.list_ids():
		var c: DroneConfig = db.get_drone(id)
		var b := Button.new()
		b.text = "%s  (%s)" % [c.display_name, c.role]
		b.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		var cid := id
		b.pressed.connect(func(): _show_detail(cid))
		list_box.add_child(b)

func _show_detail(id: String) -> void:
	selected_id = id
	var c: DroneConfig = db.get_drone(id)
	if c == null:
		return
	detail.text = "%s\n\nRole: %s\nMax speed: %.0f m/s\nAccel: %.0f\nDrag: %.1f\nTurn rate: %.1f\nBattery drain: %.1f\n\nColor preview applied in training maps." % [
		c.display_name, c.role, c.max_speed, c.accel, c.drag, c.turn_rate, c.battery_drain
	]

func _on_confirm() -> void:
	if typeof(GameState) != TYPE_NIL:
		GameState.set_drone(selected_id)
	print("Airframe selected: ", selected_id)
	get_tree().change_scene_to_file("res://scenes/ui/MainMenu.tscn")
