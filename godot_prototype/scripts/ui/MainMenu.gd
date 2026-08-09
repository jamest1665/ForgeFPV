extends Control

func _ready():
	print("MainMenu ready")
	$StartDonbas.pressed.connect(_on_donbas)
	$StartUrban.pressed.connect(_on_urban)
	$QuitButton.pressed.connect(_on_quit)

func _on_donbas():
	print("Loading Donbas")
	get_tree().change_scene_to_file("res://scenes/maps/DonbasTest.tscn")

func _on_urban():
	print("Loading Urban")
	get_tree().change_scene_to_file("res://scenes/maps/UrbanTest.tscn")

func _on_quit():
	get_tree().quit()
