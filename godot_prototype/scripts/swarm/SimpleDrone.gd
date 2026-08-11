# SimpleDrone.gd — lightweight AI airframe for swarm members
extends Node3D
class_name SimpleDrone

@export var team_id: int = 0
@export var max_speed: float = 32.0
@export var accel: float = 40.0
@export var turn_rate: float = 2.0
@export var body_color: Color = Color(0.3, 0.8, 1.0)

var velocity: Vector3 = Vector3.ZERO
var yaw: float = 0.0
var pitch: float = 0.0
var alive: bool = true
var target_pos: Vector3 = Vector3.ZERO
var has_target: bool = false

func _ready() -> void:
	_build_mesh()

func _build_mesh() -> void:
	var mesh := MeshInstance3D.new()
	var box := BoxMesh.new()
	box.size = Vector3(0.4, 0.1, 0.4)
	mesh.mesh = box
	var mat := StandardMaterial3D.new()
	mat.albedo_color = body_color
	mesh.material_override = mat
	add_child(mesh)

func set_target(pos: Vector3) -> void:
	target_pos = pos
	has_target = true

func clear_target() -> void:
	has_target = false

func apply_steering(desired: Vector3, delta: float) -> void:
	if not alive:
		return
	if desired.length_squared() < 0.0001:
		velocity = velocity.move_toward(Vector3.ZERO, accel * 0.5 * delta)
	else:
		var dir := desired.normalized()
		velocity = velocity.move_toward(dir * max_speed, accel * delta)
		yaw = lerp_angle(yaw, atan2(-dir.x, -dir.z), turn_rate * delta)
		pitch = clampf(dir.y * 0.6, -0.8, 0.8)
	global_position += velocity * delta
	if global_position.y < 1.5:
		global_position.y = 1.5
		velocity.y = maxf(velocity.y, 0.0)
	rotation = Vector3(pitch, yaw, 0.0)

func kill() -> void:
	alive = false
	visible = false
	velocity = Vector3.ZERO

func is_alive() -> bool:
	return alive
