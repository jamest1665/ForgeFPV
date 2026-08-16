# DroneVisual.gd — Phase 1 trainer airframe visual (procedural quad, not a single box)
extends Node3D
class_name DroneVisual

@export var body_color: Color = Color(0.95, 0.55, 0.1)

func _ready() -> void:
	_build()

func _build() -> void:
	for c in get_children():
		c.queue_free()

	var mat_body := StandardMaterial3D.new()
	mat_body.albedo_color = body_color
	mat_body.roughness = 0.55
	mat_body.metallic = 0.15

	var mat_arm := StandardMaterial3D.new()
	mat_arm.albedo_color = body_color.darkened(0.25)
	mat_arm.roughness = 0.7

	var mat_motor := StandardMaterial3D.new()
	mat_motor.albedo_color = Color(0.12, 0.12, 0.14)
	mat_motor.roughness = 0.4
	mat_motor.metallic = 0.6

	var mat_cam := StandardMaterial3D.new()
	mat_cam.albedo_color = Color(0.08, 0.08, 0.1)
	mat_cam.roughness = 0.3

	# central plate
	var plate := MeshInstance3D.new()
	var plate_mesh := BoxMesh.new()
	plate_mesh.size = Vector3(0.28, 0.045, 0.28)
	plate.mesh = plate_mesh
	plate.material_override = mat_body
	add_child(plate)

	# battery slab under plate
	var batt := MeshInstance3D.new()
	var batt_mesh := BoxMesh.new()
	batt_mesh.size = Vector3(0.16, 0.04, 0.22)
	batt.mesh = batt_mesh
	batt.position = Vector3(0, -0.04, 0)
	var mat_batt := StandardMaterial3D.new()
	mat_batt.albedo_color = Color(0.15, 0.35, 0.2)
	batt.material_override = mat_batt
	add_child(batt)

	# FPV camera housing
	var cam_h := MeshInstance3D.new()
	var cam_mesh := BoxMesh.new()
	cam_mesh.size = Vector3(0.06, 0.05, 0.08)
	cam_h.mesh = cam_mesh
	cam_h.position = Vector3(0, 0.02, 0.16)
	cam_h.material_override = mat_cam
	add_child(cam_h)

	# X-frame arms + motors + simple prop discs
	var arm_len := 0.22
	var offsets := [
		Vector3(1, 0, 1),
		Vector3(-1, 0, 1),
		Vector3(1, 0, -1),
		Vector3(-1, 0, -1)
	]
	for dir in offsets:
		var n := dir.normalized()
		var arm := MeshInstance3D.new()
		var arm_mesh := BoxMesh.new()
		arm_mesh.size = Vector3(0.035, 0.025, arm_len)
		arm.mesh = arm_mesh
		arm.position = n * (arm_len * 0.45)
		arm.look_at(arm.position + n, Vector3.UP)
		arm.material_override = mat_arm
		add_child(arm)

		var motor := MeshInstance3D.new()
		var cyl := CylinderMesh.new()
		cyl.top_radius = 0.028
		cyl.bottom_radius = 0.028
		cyl.height = 0.035
		motor.mesh = cyl
		motor.position = n * (arm_len * 0.85) + Vector3(0, 0.02, 0)
		motor.material_override = mat_motor
		add_child(motor)

		var prop := MeshInstance3D.new()
		var disc := CylinderMesh.new()
		disc.top_radius = 0.09
		disc.bottom_radius = 0.09
		disc.height = 0.008
		prop.mesh = disc
		prop.position = motor.position + Vector3(0, 0.025, 0)
		var mat_prop := StandardMaterial3D.new()
		mat_prop.albedo_color = Color(0.2, 0.2, 0.22, 0.55)
		mat_prop.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
		prop.material_override = mat_prop
		add_child(prop)
