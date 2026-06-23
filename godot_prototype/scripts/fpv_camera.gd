# fpv_camera.gd
# ForgeFPV Godot 4 - FPV Camera Rig

extends Camera3D
class_name FPVCamera

@export var quad_path: NodePath
@export var follow_speed: float = 20.0
@export var rotation_speed: float = 25.0
@export var fov_degrees: float = 95.0

var quad: Quadrotor

func _ready():
	if quad_path:
		quad = get_node(quad_path) as Quadrotor
	else:
		quad = get_parent() as Quadrotor

	# Apply dynamic FOV from selected drone if available
	if has_node("/root/GameState"):
		var gs = get_node("/root/GameState")
		if gs.selected_drone_config and gs.selected_drone_config.camera_fov > 0:
			fov_degrees = gs.selected_drone_config.camera_fov

	fov = fov_degrees
	current = true

func _process(delta: float):
	if not quad: return
	global_transform.origin = global_transform.origin.lerp(quad.pos, follow_speed * delta)
	var target_basis: Basis = Basis(quad.quat)
	global_transform.basis = global_transform.basis.slerp(target_basis, rotation_speed * delta)