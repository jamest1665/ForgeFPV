extends Control

func _ready():
	print("ForgeFPV MainMenu ready")

func _on_donbas():
	get_tree().change_scene_to_file("res://scenes/maps/DonbasTest.tscn")

func _on_urban():
	get_tree().change_scene_to_file("res://scenes/maps/UrbanTest.tscn")

func _on_quit():
	get_tree().quit()
