# quadrotor.gd
# Node3D wrapper around FlightModel — attach to a player drone node
extends Node3D
class_name Quadrotor

@export var body_color: Color = Color(0.95, 0.55, 0.1)
@export var max_speed: float = 45.0
@export var accel: float = 55.0

var model: FlightModel
var body: MeshInstance3D
var cam: Camera3D

func _ready() -> void:
	model = FlightModel.new()
	model.max_speed = max_speed
	model.accel = accel
	model.reset(global_position)
	_build_visual()
	_build_camera()

func _build_visual() -> void:
	body = MeshInstance3D.new()
	body.name = "Body"
	var box := BoxMesh.new()
	box.size = Vector3(0.55, 0.12, 0.55)
	body.mesh = box
	var mat := StandardMaterial3D.new()
	mat.albedo_color = body_color
	body.material_override = mat
	add_child(body)

func _build_camera() -> void:
	cam = Camera3D.new()
	cam.name = "FPVCamera"
	cam.current = true
	cam.fov = 100.0
	cam.position = Vector3(0, 0.08, 0.15)
	add_child(cam)

func _physics_process(delta: float) -> void:
	if model == null:
		return
	model.read_input(delta)
	model.step(delta)
	global_position = model.pos
	rotation = model.get_rotation()

func set_wind(w: Vector3) -> void:
	if model:
		model.wind = w

func get_telemetry() -> Dictionary:
	if model:
		return model.get_telemetry()
	return {}

func get_score_position() -> Vector3:
	return global_position
