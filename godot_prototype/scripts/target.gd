# target.gd
# Red scoring target — proximity hit detection
extends Node3D
class_name TrainingTarget

signal hit(target_id: int, points: int)

@export var target_id: int = 0
@export var hit_radius: float = 4.0
@export var points: int = 100
@export var already_hit: bool = false

var mesh: MeshInstance3D

func _ready() -> void:
	if mesh == null:
		_build_mesh()

func _build_mesh() -> void:
	mesh = MeshInstance3D.new()
	var box := BoxMesh.new()
	box.size = Vector3(2.2, 2.0, 2.2)
	mesh.mesh = box
	var mat := StandardMaterial3D.new()
	mat.albedo_color = Color(0.9, 0.2, 0.1)
	mat.emission_enabled = true
	mat.emission = Color(0.7, 0.1, 0.05)
	mat.emission_energy_multiplier = 0.9
	mesh.material_override = mat
	add_child(mesh)

static func spawn(parent: Node, id: int, at: Vector3) -> TrainingTarget:
	var t := TrainingTarget.new()
	t.target_id = id
	t.position = at
	parent.add_child(t)
	return t

func try_hit(player_pos: Vector3) -> bool:
	if already_hit:
		return false
	if player_pos.distance_to(global_position) > hit_radius:
		return false
	already_hit = true
	visible = false
	hit.emit(target_id, points)
	return true
