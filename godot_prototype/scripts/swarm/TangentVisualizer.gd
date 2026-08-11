# TangentVisualizer.gd — draws the ring path for tangential formation
extends Node3D
class_name TangentVisualizer

var controller: TangentialController
var mesh_instance: MeshInstance3D
var immediate: ImmediateMesh
var segments: int = 48
var color: Color = Color(0.2, 0.9, 0.6, 0.45)

func _ready() -> void:
	immediate = ImmediateMesh.new()
	mesh_instance = MeshInstance3D.new()
	mesh_instance.mesh = immediate
	var mat := StandardMaterial3D.new()
	mat.albedo_color = color
	mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	mesh_instance.material_override = mat
	add_child(mesh_instance)

func set_controller(c: TangentialController) -> void:
	controller = c
	_rebuild()

func _rebuild() -> void:
	if immediate == null or controller == null:
		return
	immediate.clear_surfaces()
	immediate.surface_begin(Mesh.PRIMITIVE_LINE_STRIP)
	for i in range(segments + 1):
		var t := float(i) / float(segments) * TAU
		var p := controller.center + Vector3(cos(t) * controller.radius, controller.height, sin(t) * controller.radius)
		immediate.surface_set_color(color)
		immediate.surface_add_vertex(p)
	immediate.surface_end()
