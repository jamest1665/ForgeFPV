# DroneVisual.gd — simple colored body mesh for trainer airframe
extends Node3D
class_name DroneVisual

@export var body_color: Color = Color(0.95, 0.55, 0.1)

func _ready() -> void:
	var mesh := MeshInstance3D.new()
	var box := BoxMesh.new()
	box.size = Vector3(0.55, 0.12, 0.55)
	mesh.mesh = box
	var mat := StandardMaterial3D.new()
	mat.albedo_color = body_color
	mesh.material_override = mat
	add_child(mesh)
	# simple arms
	for offset in [Vector3(0.25, 0, 0.25), Vector3(-0.25, 0, 0.25), Vector3(0.25, 0, -0.25), Vector3(-0.25, 0, -0.25)]:
		var arm := MeshInstance3D.new()
		var abox := BoxMesh.new()
		abox.size = Vector3(0.08, 0.04, 0.08)
		arm.mesh = abox
		arm.position = offset
		var amat := StandardMaterial3D.new()
		amat.albedo_color = body_color.darkened(0.2)
		arm.material_override = amat
		add_child(arm)
