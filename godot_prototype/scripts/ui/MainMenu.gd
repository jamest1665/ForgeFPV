# MainMenu.gd
# Simple working main menu - loads Donbas / Urban maps

extends Control

func _ready() -> void:
	_build_ui()
	print("MainMenu: Ready")

func _build_ui() -> void:
	for c in get_children():
		if c.name != "Background":
			c.queue_free()

	var title := Label.new()
	title.name = "Title"
	title.text = "ForgeFPV - Tactical Drone Trainer"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.set_anchors_preset(Control.PRESET_TOP_WIDE)
	title.offset_top = 40
	title.offset_bottom = 80
	add_child(title)

	var btn_donbas := Button.new()
	btn_donbas.name = "StartDonbas"
	btn_donbas.text = "Start Donbas Training"
	btn_donbas.set_anchors_preset(Control.PRESET_CENTER)
	btn_donbas.position = Vector2(-120, -40)
	btn_donbas.custom_minimum_size = Vector2(240, 40)
	btn_donbas.pressed.connect(_on_donbas)
	add_child(btn_donbas)

	var btn_urban := Button.new()
	btn_urban.name = "StartUrban"
	btn_urban.text = "Start Urban Training"
	btn_urban.set_anchors_preset(Control.PRESET_CENTER)
	btn_urban.position = Vector2(-120, 20)
	btn_urban.custom_minimum_size = Vector2(240, 40)
	btn_urban.pressed.connect(_on_urban)
	add_child(btn_urban)

	var btn_quit := Button.new()
	btn_quit.name = "Quit"
	btn_quit.text = "Quit"
	btn_quit.set_anchors_preset(Control.PRESET_CENTER)
	btn_quit.position = Vector2(-120, 80)
	btn_quit.custom_minimum_size = Vector2(240, 40)
	btn_quit.pressed.connect(func(): get_tree().quit())
	add_child(btn_quit)

func _on_donbas() -> void:
	print("MainMenu: Loading Donbas...")
	get_tree().change_scene_to_file("res://scenes/maps/DonbasTest.tscn")

func _on_urban() -> void:
	print("MainMenu: Loading Urban...")
	get_tree().change_scene_to_file("res://scenes/maps/UrbanTest.tscn")
