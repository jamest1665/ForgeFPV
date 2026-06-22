# autonomy_example.gd
# ForgeFPV Godot 4 - Autonomy Integration Layer (Production Foundation)

extends Node
class_name AutonomyExample

@export var quad_path: NodePath
@export var enabled: bool = true
@export var behavior: String = "hover"

var quad: Quadrotor
var patrol_points: Array[Vector3] = []
var current_patrol_index: int = 0
var target_position: Vector3 = Vector3(12, 4, 3.5)

func _ready():
	if quad_path:
		quad = get_node(quad_path) as Quadrotor
	else:
		quad = get_tree().get_first_node_in_group("quadrotor") as Quadrotor

	patrol_points = [
		Vector3(8, 6, 4),
		Vector3(-6, 8, 3.5),
		Vector3(-10, -5, 5),
		Vector3(5, -7, 4)
	]

	print("AutonomyExample ready. Current behavior:", behavior)

func _physics_process(delta: float):
	if not enabled or not quad: return

	match behavior:
		"hover":
			_do_hover()
		"approach_target":
			_do_approach_target()
		"engage":
			_do_engage()
		"patrol":
			_do_patrol()

func _do_hover():
	var throttle = 0.52
	var roll = clamp(-quad.omega.x * 2.5, -0.7, 0.7)
	var pitch = clamp(-quad.omega.y * 2.5, -0.7, 0.7)
	var yaw = 0.0
	quad.apply_control(throttle, roll, pitch, yaw)

func _do_approach_target():
	var to_target = target_position - quad.pos
	var dist = Vector2(to_target.x, to_target.y).length()

	var throttle = 0.52
	var roll = clamp(to_target.y * 0.09, -0.65, 0.65)
	var pitch = clamp(-to_target.x * 0.09, -0.65, 0.65)
	var yaw = clamp(atan2(to_target.y, to_target.x) * 0.4, -0.5, 0.5)

	quad.apply_control(throttle, roll, pitch, yaw)

	if dist < 7.0 and quad.try_engage_target():
		print("Autonomy: Target engaged!")

func _do_engage():
	_do_approach_target()
	if quad.try_engage_target():
		print("Autonomy: Engagement successful!")
		behavior = "hover"

func _do_patrol():
	if patrol_points.is_empty(): return

	var target = patrol_points[current_patrol_index]
	var to_target = target - quad.pos
	var dist = Vector2(to_target.x, to_target.y).length()

	var throttle = 0.52
	var roll = clamp(to_target.y * 0.07, -0.6, 0.6)
	var pitch = clamp(-to_target.x * 0.07, -0.6, 0.6)

	quad.apply_control(throttle, roll, pitch, 0.0)

	if dist < 4.0:
		current_patrol_index = (current_patrol_index + 1) % patrol_points.size()