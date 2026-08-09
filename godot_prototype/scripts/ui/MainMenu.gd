extends Control

func _ready():
	print("MainMenu: Ready")
	$StartDonbas.pressed.connect(_on_donbas)
	$StartUrban.pressed.connect(_on_urban)
	$QuitButton.pressed.connect(_on_quit)

func _on_donbas():
	print("Loading Donbas...")
	var err = get_tree().change_scene_to_file("res://scenes/maps/DonbasTest.tscn")
	if err != OK:
		print("ERROR loading Donbas: ", err)

func _on_urban():
	print("Loading Urban...")
	var err = get_tree().change_scene_to_file("res://scenes/maps/UrbanTest.tscn")
	if err != OK:
		print("ERROR loading Urban: ", err)

func _on_quit():
	get_tree().quit()
