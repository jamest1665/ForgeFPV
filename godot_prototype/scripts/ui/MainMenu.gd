extends Control

func _ready():
	print("ForgeFPV MainMenu ready")

func _on_missions():
	get_tree().change_scene_to_file("res://scenes/ui/MissionSelection.tscn")

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
