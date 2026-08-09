# MainMenu.gd
# Full-screen visible menu - guaranteed buttons on screen

extends Control

func _ready() -> void:
	# Fill entire window
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_STOP
	_build_ui()
	print("MainMenu: Ready - UI built")

func _build_ui() -> void:
	# Remove old dynamic children except Background
	for c in get_children():
		if c.name != "Background":
			c.queue_free()

	# Dark background if missing
	if not has_node("Background"):
		var bg := ColorRect.new()
		bg.name = "Background"
		bg.color = Color(0.06, 0.07, 0.1, 1)
		bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
		add_child(bg)
		move_child(bg, 0)
	else:
		$Background.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		$Background.color = Color(0.06, 0.07, 0.1, 1)

	var title := Label.new()
	title.name = "Title"
	title.text = "ForgeFPV - Tactical Drone Trainer"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 28)
	title.set_anchors_preset(Control.PRESET_TOP_WIDE)
	title.offset_top = 60
	title.offset_bottom = 120
	add_child(title)

	var center := VBoxContainer.new()
	center.name = "ButtonBox"
	center.alignment = BoxContainer.ALIGNMENT_CENTER
	center.set_anchors_preset(Control.PRESET_CENTER)
	center.offset_left = -160
	center.offset_right = 160
	center.offset_top = -80
	center.offset_bottom = 120
	add_child(center)

	var btn_donbas := Button.new()
	btn_donbas.text = "Start Donbas Training"
	btn_donbas.custom_minimum_size = Vector2(320, 48)
	btn_donbas.pressed.connect(_on_donbas)
	center.add_child(btn_donbas)

	var spacer1 := Control.new()
	spacer1.custom_minimum_size = Vector2(0, 12)
	center.add_child(spacer1)

	var btn_urban := Button.new()
	btn_urban.text = "Start Urban Training"
	btn_urban.custom_minimum_size = Vector2(320, 48)
	btn_urban.pressed.connect(_on_urban)
	center.add_child(btn_urban)

	var spacer2 := Control.new()
	spacer2.custom_minimum_size = Vector2(0, 12)
	center.add_child(spacer2)

	var btn_quit := Button.new()
	btn_quit.text = "Quit"
	btn_quit.custom_minimum_size = Vector2(320, 48)
	btn_quit.pressed.connect(func(): get_tree().quit())
	center.add_child(btn_quit)

func _on_donbas() -> void:
	print("MainMenu: Loading Donbas...")
	var err := get_tree().change_scene_to_file("res://scenes/maps/DonbasTest.tscn")
	if err != OK:
		push_error("Failed to load DonbasTest.tscn error=" + str(err))

func _on_urban() -> void:
	print("MainMenu: Loading Urban...")
	var err := get_tree().change_scene_to_file("res://scenes/maps/UrbanTest.tscn")
	if err != OK:
		push_error("Failed to load UrbanTest.tscn error=" + str(err))
