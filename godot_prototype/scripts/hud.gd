# hud.gd
# ForgeFPV Godot 4 - Production HUD with High-Quality Artificial Horizon + Sky/Ground
# This version includes tilted sky and ground coloring for better FPV immersion.

extends CanvasLayer
class_name HUD

@export var quad_path: NodePath
@export var game_manager_path: NodePath

var quad: Quadrotor
var game_manager: GameManager

@onready var score_label: Label = $ScoreLabel
@onready var mode_label: Label = $ModeLabel
@onready var battery_bar: ProgressBar = $BatteryBar
@onready var feedback_label: Label = $FeedbackLabel
@onready var ew_label: Label = $EWLabel
@onready var horizon_control: Control = $HorizonControl

var feedback_timer: float = 0.0

func _ready():
	if quad_path:
		quad = get_node(quad_path) as Quadrotor
	else:
		quad = get_tree().get_first_node_in_group("quadrotor") as Quadrotor

	if game_manager_path:
		game_manager = get_node(game_manager_path) as GameManager
	else:
		game_manager = get_tree().get_first_node_in_group("game_manager") as GameManager

	if game_manager:
		game_manager.score_updated.connect(_on_score_updated)
		game_manager.mode_changed.connect(_on_mode_changed)
		game_manager.engagement_result.connect(_on_engagement_result)

	if feedback_label:
		feedback_label.text = ""
		feedback_label.modulate.a = 0.0

	if horizon_control:
		horizon_control.custom_minimum_size = Vector2(420, 320)
		horizon_control.draw.connect(_on_horizon_control_draw)

func _process(delta: float):
	if quad:
		if battery_bar:
			battery_bar.value = quad.battery
		if ew_label:
			ew_label.text = "EW: " + ("JAMMED" if quad.ew_active else "CLEAR")
			ew_label.modulate = Color(1, 0.25, 0.25) if quad.ew_active else Color(0.25, 1, 0.4)

	if feedback_timer > 0:
		feedback_timer -= delta
		if feedback_timer <= 0 and feedback_label:
			var tween = create_tween()
			tween.tween_property(feedback_label, "modulate:a", 0.0, 0.7)

	if horizon_control:
		horizon_control.queue_redraw()

func _on_score_updated(new_score: int):
	if score_label:
		score_label.text = "SCORE: %d" % new_score

func _on_mode_changed(new_mode: int):
	if mode_label:
		mode_label.text = "MODE: %s" % GameManager.Mode.keys()[new_mode]

func _on_engagement_result(success: bool, quality: float):
	if not feedback_label: return
	if success:
		var q_text = "PERFECT" if quality > 0.9 else ("SMOOTH" if quality > 0.75 else "GOOD")
		feedback_label.text = "%s APPROACH +%d" % [q_text, int(quality * 40)]
		feedback_label.modulate = Color(0.2, 1, 0.5, 1)
	else:
		feedback_label.text = "MISS"
		feedback_label.modulate = Color(1, 0.35, 0.35, 1)
	feedback_label.modulate.a = 1.0
	feedback_timer = 2.2

# ==================== PRODUCTION ARTIFICIAL HORIZON WITH SKY/GROUND ====================
func _on_horizon_control_draw():
	if not horizon_control or not quad: return

	var center = horizon_control.size / 2.0
	var roll = quad.omega.x * 0.55
	var pitch = quad.omega.y * 0.45

	var angle = -roll * 0.75
	var line_len = 170.0
	var dx = cos(angle) * line_len
	var dy = sin(angle) * line_len * 0.48
	var pitch_off = pitch * 5.0

	# Background
	horizon_control.draw_rect(Rect2(Vector2.ZERO, horizon_control.size), Color(0.05, 0.05, 0.1), true)

	# Sky region (above horizon)
	var sky_points = PackedVector2Array()
	sky_points.append(center - Vector2(dx, dy) + Vector2(0, pitch_off))
	sky_points.append(center + Vector2(dx, dy) + Vector2(0, pitch_off))
	sky_points.append(Vector2(horizon_control.size.x, 0))
	sky_points.append(Vector2(0, 0))
	horizon_control.draw_polygon(sky_points, [Color(0.35, 0.55, 0.85, 0.25)])

	# Ground region (below horizon)
	var ground_points = PackedVector2Array()
	ground_points.append(center - Vector2(dx, dy) + Vector2(0, pitch_off))
	ground_points.append(center + Vector2(dx, dy) + Vector2(0, pitch_off))
	ground_points.append(Vector2(horizon_control.size.x, horizon_control.size.y))
	ground_points.append(Vector2(0, horizon_control.size.y))
	horizon_control.draw_polygon(ground_points, [Color(0.45, 0.38, 0.25, 0.25)])

	# Horizon line
	horizon_control.draw_line(
		center - Vector2(dx, dy) + Vector2(0, pitch_off),
		center + Vector2(dx, dy) + Vector2(0, pitch_off),
		Color(1, 0.88, 0.2), 4.0
	)

	# Pitch ladder
	for p in range(-35, 40, 5):
		var yo = (p - pitch * 9.0) * 3.5
		if abs(yo) > 120: continue
		var half_w = 28 if p % 10 == 0 else 14
		horizon_control.draw_line(
			center + Vector2(-half_w, yo),
			center + Vector2(half_w, yo),
			Color(0.9, 0.9, 0.9, 0.85), 1.8
		)
		if p != 0 and p % 10 == 0:
			horizon_control.draw_string(
			ThemeDB.fallback_font,
			center + Vector2(half_w + 5, yo + 4),
			str(p),
			HORIZONTAL_ALIGNMENT_LEFT, -1, 13, Color(0.85, 0.85, 0.85)
			)

	# Center reticle
	horizon_control.draw_circle(center, 7, Color(0, 1, 0.4, 0.95), false, 2.3)
	horizon_control.draw_line(center - Vector2(28, 0), center + Vector2(28, 0), Color(0, 1, 0.4), 1.8)
	horizon_control.draw_line(center - Vector2(0, 28), center + Vector2(0, 28), Color(0, 1, 0.4), 1.8)

	# Velocity vector
	var vel_dir = Vector2(quad.vel.x, -quad.vel.z).normalized() * 40
	horizon_control.draw_line(center, center + vel_dir, Color(1, 0.5, 0.1, 0.8), 2.5)