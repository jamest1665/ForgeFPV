# target.gd
# ForgeFPV Godot 4 - Reusable target for engagement training

extends Node3D
class_name Target

@export var game_manager_path: NodePath
@export var respawn_radius: float = 12.0
@export var points_value: int = 100

var game_manager: GameManager
var is_active: bool = true

func _ready():
	game_manager = get_node(game_manager_path) as GameManager

func try_engage(quad_pos: Vector3, quad_quat: Quaternion, quad_vel: Vector3, quad_omega: Vector3) -> bool:
	if not is_active: return false

	var rel = global_transform.origin - quad_pos
	var dist = rel.length()
	if dist > 22.0 or dist < 0.8: return false

	var forward = (Basis(quad_quat) * Vector3.FORWARD).normalized()
	var to_target = rel.normalized()
	var angle = rad_to_deg(acos(forward.dot(to_target)))

	if angle > 16.0: return false

	var speed = quad_vel.length()
	var rate_mag = quad_omega.length()
	var quality = max(0.6, 1.0 - (speed * 0.04 + rate_mag * 0.8))
	var bonus = int(40 * quality)
	var total_points = points_value + bonus

	is_active = false
	if game_manager:
		game_manager.on_target_engaged(true, quality, total_points)

	visible = false
	await get_tree().create_timer(1.5).timeout
	respawn()
	return true

func respawn():
	var q = get_tree().get_first_node_in_group("quadrotor") as Quadrotor
	if q:
		global_transform.origin = q.pos + Vector3(randf_range(9, 16), randf_range(-10, 10), randf_range(1.8, 4.2))
	else:
		global_transform.origin = Vector3(randf_range(-15, 15), randf_range(-15, 15), randf_range(1.5, 5))

	is_active = true
	visible = true