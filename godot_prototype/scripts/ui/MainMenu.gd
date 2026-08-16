extends Control

func _ready() -> void:
	print("ForgeFPV MainMenu ready v", ProjectSettings.get_setting("application/config/version", "?"))
	_ensure_version_label()

func _ensure_version_label() -> void:
	if has_node("VersionLabel"):
		return
	var lab := Label.new()
	lab.name = "VersionLabel"
	lab.text = "v%s" % str(ProjectSettings.get_setting("application/config/version", "0.2.0"))
	lab.position = Vector2(16, 690)
	lab.add_theme_font_size_override("font_size", 14)
	add_child(lab)

func _on_missions():
	get_tree().change_scene_to_file("res://scenes/ui/MissionSelection.tscn")

func _on_airframe():
	get_tree().change_scene_to_file("res://scenes/ui/DroneSelection.tscn")

func _on_instructions():
	get_tree().change_scene_to_file("res://scenes/ui/Instructions.tscn")

func _on_scenario():
	get_tree().change_scene_to_file("res://scenes/ui/ScenarioSelector.tscn")

func _on_settings():
	get_tree().change_scene_to_file("res://scenes/ui/SettingsMenu.tscn")

func _on_autonomy():
	get_tree().change_scene_to_file("res://scenes/maps/AutonomyDemo.tscn")

func _on_donbas():
	get_tree().change_scene_to_file("res://scenes/maps/DonbasTest.tscn")

func _on_urban():
	get_tree().change_scene_to_file("res://scenes/maps/UrbanTest.tscn")

func _on_aquatic():
	get_tree().change_scene_to_file("res://scenes/maps/aquatic_flood/AquaticTest.tscn")

func _on_taiwan():
	get_tree().change_scene_to_file("res://scenes/maps/global_06_taiwan_littoral/TaiwanTest.tscn")

func _on_arctic():
	get_tree().change_scene_to_file("res://scenes/maps/arctic/ArcticTest.tscn")

func _on_border():
	get_tree().change_scene_to_file("res://scenes/maps/border/BorderTest.tscn")

func _on_laport():
	get_tree().change_scene_to_file("res://scenes/maps/la_port/LAPortTest.tscn")

func _on_quit():
	get_tree().quit()
