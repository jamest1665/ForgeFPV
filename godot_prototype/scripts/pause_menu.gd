# pause_menu.gd
# ForgeFPV Godot 4 - Simple Production Pause Menu

extends Control
class_name PauseMenu

@export var game_manager_path: NodePath
@export var quad_path: NodePath

var game_manager: GameManager
var quad: Quadrotor
var is_paused: bool = false

@onready var panel: Panel = $Panel
@onready var resume_button: Button = $Panel/VBoxContainer/ResumeButton
@onready var reset_button: Button = $Panel/VBoxContainer/ResetButton
@onready var quit_button: Button = $Panel/VBoxContainer/QuitButton

func _ready():
	visible = false
	process_mode = Node.PROCESS_MODE_ALWAYS

	if game_manager_path:
		game_manager = get_node(game_manager_path) as GameManager
	else:
		game_manager = get_tree().get_first_node_in_group("game_manager") as GameManager

	if quad_path:
		quad = get_node(quad_path) as Quadrotor
	else:
		quad = get_tree().get_first_node_in_group("quadrotor") as Quadrotor

	if resume_button:
		resume_button.pressed.connect(_on_resume_pressed)
	if reset_button:
		reset_button.pressed.connect(_on_reset_pressed)
	if quit_button:
		quit_button.pressed.connect(_on_quit_pressed)

func _unhandled_input(event: InputEvent):
	if event.is_action_pressed("ui_cancel"):
		toggle_pause()
		get_viewport().set_input_as_handled()

func toggle_pause():
	is_paused = not is_paused
	visible = is_paused
	get_tree().paused = is_paused

	if is_paused:
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	else:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _on_resume_pressed():
	toggle_pause()

func _on_reset_pressed():
	if game_manager:
		game_manager.reset_session()
	toggle_pause()

func _on_quit_pressed():
	get_tree().quit()