extends Control

func _ready():
	print("MainMenu: Ready")
	var donbas = get_node_or_null("StartDonbas")
	if donbas:
		donbas.pressed.connect(_on_donbas)
	var urban = get_node_or_null("StartUrban")
	if urban:
		urban.pressed.connect(_on_urban)
	var quit_btn = get_node_or_null("QuitButton")
	if quit_btn:
		quit_btn.pressed.connect(_on_quit)

func _on_donbas():
	get_tree().change_scene_to_file("res://scenes/maps/DonbasTest.tscn")

func _on_urban():
	get_tree().change_scene_to_file("res://scenes/maps/UrbanTest.tscn")

func _on_quit():
	get_tree().quit()
