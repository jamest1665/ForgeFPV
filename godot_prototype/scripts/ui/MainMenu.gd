extends Control

func _ready():
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_build_ui()
	print("MainMenu: Ready - UI built")

func _build_ui():
	var kids = get_children()
	for c in kids:
		if str(c.name) != "Background":
			c.queue_free()

	if not has_node("Background"):
		var bg = ColorRect.new()
		bg.name = "Background"
		bg.color = Color(0.06, 0.07, 0.1, 1)
		bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		add_child(bg)
		move_child(bg, 0)

	var title = Label.new()
	title.name = "Title"
	title.text = "ForgeFPV - Tactical Drone Trainer"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 28)
	title.set_anchors_preset(Control.PRESET_TOP_WIDE)
	title.offset_top = 50
	title.offset_bottom = 110
	add_child(title)

	var btn1 = Button.new()
	btn1.name = "StartDonbas"
	btn1.text = "Start Donbas Training"
	btn1.set_anchors_preset(Control.PRESET_CENTER)
	btn1.offset_left = -160
	btn1.offset_right = 160
	btn1.offset_top = -40
	btn1.offset_bottom = 8
	btn1.pressed.connect(_on_donbas)
	add_child(btn1)

	var btn2 = Button.new()
	btn2.name = "StartUrban"
	btn2.text = "Start Urban Training"
	btn2.set_anchors_preset(Control.PRESET_CENTER)
	btn2.offset_left = -160
	btn2.offset_right = 160
	btn2.offset_top = 20
	btn2.offset_bottom = 68
	btn2.pressed.connect(_on_urban)
	add_child(btn2)

	var btn3 = Button.new()
	btn3.name = "QuitButton"
	btn3.text = "Quit"
	btn3.set_anchors_preset(Control.PRESET_CENTER)
	btn3.offset_left = -160
	btn3.offset_right = 160
	btn3.offset_top = 80
	btn3.offset_bottom = 128
	btn3.pressed.connect(_on_quit)
	add_child(btn3)

func _on_donbas():
	print("MainMenu: Loading Donbas...")
	get_tree().change_scene_to_file("res://scenes/maps/DonbasTest.tscn")

func _on_urban():
	print("MainMenu: Loading Urban...")
	get_tree().change_scene_to_file("res://scenes/maps/UrbanTest.tscn")

func _on_quit():
	get_tree().quit()
