# PathTrail.gd — lightweight path ribbon for training / debrief
extends Node3D
class_name PathTrail

@export var max_points: int = 120
@export var min_dist: float = 0.6
@export var trail_color: Color = Color(1.0, 0.7, 0.2, 0.55)

var points: PackedVector3Array = PackedVector3Array()
var mesh_instance: MeshInstance3D
var immediate: ImmediateMesh
var follow_target: Node3D

func _ready() -> void:
	immediate = ImmediateMesh.new()
	mesh_instance = MeshInstance3D.new()
	mesh_instance.mesh = immediate
	var mat := StandardMaterial3D.new()
	mat.albedo_color = trail_color
	mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	mat.vertex_color_use_as_albedo = true
	mesh_instance.material_override = mat
	add_child(mesh_instance)

func set_follow(target: Node3D) -> void:
	follow_target = target

func clear_trail() -> void:
	points.clear()
	_rebuild()

func _process(_delta: float) -> void:
	if follow_target == null or not is_instance_valid(follow_target):
		return
	var p := follow_target.global_position
	if points.is_empty() or points[points.size() - 1].distance_to(p) >= min_dist:
		points.append(p)
		while points.size() > max_points:
			points.remove_at(0)
		_rebuild()

func _rebuild() -> void:
	if immediate == null:
		return
	immediate.clear_surfaces()
	if points.size() < 2:
		return
	immediate.surface_begin(Mesh.PRIMITIVE_LINE_STRIP)
	for p in points:
		immediate.surface_set_color(trail_color)
		immediate.surface_add_vertex(p)
	immediate.surface_end()
