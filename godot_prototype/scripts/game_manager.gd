# game_manager.gd
# ForgeFPV Godot 4 - Training Scenario & UI Foundation

extends Node
class_name GameManager

enum Mode {
	FREE_FLIGHT,
	PRECISION_ENGAGE,
	EW_CHALLENGE
}

@export var quad_path: NodePath
@export var targets_container_path: NodePath
@export var hud_path: NodePath

var current_mode: Mode = Mode.FREE_FLIGHT
var quad: Quadrotor
var targets_container: Node
var hud: CanvasLayer

var score: int = 0

signal mode_changed(new_mode: Mode)
signal score_updated(new_score: int)
signal engagement_result(success: bool, quality: float)

func _ready():
	quad = get_node(quad_path) as Quadrotor
	targets_container = get_node(targets_container_path)
	hud = get_node(hud_path) as CanvasLayer

	set_mode(Mode.FREE_FLIGHT)

func set_mode(new_mode: Mode):
	current_mode = new_mode

	match current_mode:
		Mode.FREE_FLIGHT:
			quad.ew_active = false
			quad.wind_base = Vector3(0.8, -0.5, 0.2)
		Mode.PRECISION_ENGAGE:
			quad.ew_active = false
			quad.wind_base = Vector3(1.5, -1.0, 0.4)
		Mode.EW_CHALLENGE:
			quad.ew_active = true
			quad.wind_base = Vector3(2.0, -1.5, 0.6)

	emit_signal("mode_changed", current_mode)

func add_score(points: int):
	score += points
	emit_signal("score_updated", score)

func reset_session():
	quad.reset()
	score = 0
	emit_signal("score_updated", score)

	for child in targets_container.get_children():
		if child.has_method("respawn"):
			child.respawn()

func _unhandled_input(event):
	if event.is_action_pressed("ui_cancel"):
		reset_session()
	if event.is_action_pressed("change_mode"):
		var next = (current_mode + 1) % Mode.size()
		set_mode(next as Mode)

func on_target_engaged(success: bool, quality: float, points: int):
	if success:
		add_score(points)
		emit_signal("engagement_result", true, quality)