# main_example.gd
# ForgeFPV Godot 4 - Production Example Scene Orchestrator
# Attach this script to the root node of a new 3D scene for the fastest way to get a playable prototype.

extends Node
class_name MainExample

@export var number_of_targets: int = 5
@export var spawn_radius: float = 18.0

var quad: Quadrotor
var game_manager: GameManager
var hud: HUD
var fpv_camera: FPVCamera

func _ready():
	print("=== ForgeFPV Production Example Scene Initializing ===")

	# Create Quad
	quad = Quadrotor.new()
	quad.name = "Quad"
	quad.add_to_group("quadrotor")
	add_child(quad)
	quad.global_position = Vector3(0, 0, 5.0)

	# Create GameManager
	game_manager = GameManager.new()
	game_manager.name = "GameManager"
	game_manager.add_to_group("game_manager")
	game_manager.quad = quad
	add_child(game_manager)

	# Create HUD
	hud = HUD.new()
	hud.name = "HUD"
	hud.quad = quad
	hud.game_manager = game_manager
	add_child(hud)

	# Create HorizonControl
	var horizon = Control.new()
	horizon.name = "HorizonControl"
	horizon.custom_minimum_size = Vector2(420, 320)
	horizon.position = Vector2(430, 180)
	hud.add_child(horizon)

	# Setup FPV Camera
	fpv_camera = FPVCamera.new()
	fpv_camera.name = "FPVCamera"
	quad.add_child(fpv_camera)
	fpv_camera.quad = quad

	# Spawn targets
	for i in range(number_of_targets):
		var target = Target.new()
		target.name = "Target_%d" % i
		target.game_manager = game_manager
		var angle = (i / float(number_of_targets)) * TAU
		target.global_position = Vector3(
			cos(angle) * spawn_radius * randf_range(0.6, 1.0),
			sin(angle) * spawn_radius * randf_range(0.6, 1.0),
			randf_range(2.0, 6.0)
		)
		add_child(target)

	print("ForgeFPV Example ready. Controls: WASD/Arrows + Q/E | Tab = Change Mode | J = Toggle EW | ESC = Reset")

func _unhandled_input(event: InputEvent):
	if event.is_action_pressed("ui_cancel"):
		if game_manager:
			game_manager.reset_session()
	if event.is_action_pressed("change_mode") and game_manager:
		var next = (game_manager.current_mode + 1) % GameManager.Mode.size()
		game_manager.set_mode(next as GameManager.Mode)
	if event.is_action_pressed("toggle_ew") and quad:
		quad.toggle_ew()