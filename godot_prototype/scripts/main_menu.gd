# main_menu.gd
# ForgeFPV Godot 4 - Simple Production Title / Main Menu

extends Control
class_name MainMenu

@export var training_scene_path: String = "res://main_training.tscn"

@onready var start_button: Button = $VBoxContainer/StartButton
@onready var options_button: Button = $VBoxContainer/OptionsButton
@onready var quit_button: Button = $VBoxContainer/QuitButton
@onready var title_label: Label = $TitleLabel

func _ready():
	if start_button:
		start_button.pressed.connect(_on_start_pressed)
	if options_button:
		options_button.pressed.connect(_on_options_pressed)
	if quit_button:
		quit_button.pressed.connect(_on_quit_pressed)

	if title_label:
		title_label.text = "FORGEFPV"

func _on_start_pressed():
	if training_scene_path != "":
		get_tree().change_scene_to_file(training_scene_path)
	else:
		print("Please set the training_scene_path in the MainMenu inspector.")

func _on_options_pressed():
	print("Options menu not yet implemented.")

func _on_quit_pressed():
	get_tree().quit()