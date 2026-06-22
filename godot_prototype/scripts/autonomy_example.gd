# autonomy_example.gd
# ForgeFPV Godot 4 - First Autonomy Integration Example
# Demonstrates how external code or AI can control the Quadrotor.

extends Node
class_name AutonomyExample

@export var quad_path: NodePath
@export var enabled: bool = true
@export var behavior: String = "hover"

var quad: Quadrotor
var target_position: Vector3 = Vector3(10, 5, 4)

func _ready():
	if quad_path:
		quad = get_node(quad_path) as Quadrotor
	else:
		quad = get_tree().get_first_node_in_group("quadrotor") as Quadrotor
	print("AutonomyExample initialized. Behavior:", behavior)

func _physics_process(delta: float):
	if not enabled or not quad: return

	match behavior:
		"hover":
			_hover_behavior(delta)
		"approach_target":
			_approach_target_behavior(delta)
		"engage":
			_engage_behavior(delta)

func _hover_behavior(delta: float):
	var throttle = 0.52
	var roll = clamp(-quad.omega.x * 2.0, -0.8, 0.8)
	var pitch = clamp(-quad.omega.y * 2.0, -0.8, 0.8)
	var yaw = 0.0
	quad.apply_control(throttle, roll, pitch, yaw)

func _approach_target_behavior(delta: float):
	var to_target = target_position - quad.pos
	var horizontal_dist = Vector2(to_target.x, to_target.y).length()

	var throttle = 0.52
	var desired_yaw = atan2(to_target.y, to_target.x)

	var roll = clamp(to_target.y * 0.08, -0.6, 0.6)
	var pitch = clamp(-to_target.x * 0.08, -0.6, 0.6)
	var yaw = clamp((desired_yaw - quad.omega.z) * 0.5, -0.5, 0.5)

	quad.apply_control(throttle, roll, pitch, yaw)

	if horizontal_dist < 8.0 and quad.try_engage_target():
		print("Autonomy: Engaged target!")

func _engage_behavior(delta: float):
	_approach_target_behavior(delta)
	if quad.try_engage_target():
		print("Autonomy: Successful engagement!")
		behavior = "hover"