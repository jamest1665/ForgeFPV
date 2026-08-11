# DonbasTestScene.gd — field training on shared BaseTrainingScene core
extends BaseTrainingScene

func _init() -> void:
	map_name = "DONBAS"
	wind_preset = "field"
	weather_preset = "clear"
	spawn_height = 15.0
	body_color = Color(0.95, 0.55, 0.1)

func _build_world() -> void:
	var ground := MeshInstance3D.new()
	var plane := PlaneMesh.new()
	plane.size = Vector2(500, 500)
	ground.mesh = plane
	var mat := StandardMaterial3D.new()
	mat.albedo_color = Color(0.42, 0.36, 0.24)
	ground.material_override = mat
	add_child(ground)

	var light := DirectionalLight3D.new()
	light.light_energy = 1.4
	light.shadow_enabled = true
	light.rotation_degrees = Vector3(-55, 30, 0)
	add_child(light)

	var rng := RandomNumberGenerator.new()
	rng.seed = 42
	for i in range(18):
		var b := MeshInstance3D.new()
		var box := BoxMesh.new()
		var h := rng.randf_range(2.0, 9.0)
		box.size = Vector3(rng.randf_range(3.0, 8.0), h, rng.randf_range(3.0, 8.0))
		b.mesh = box
		var bm := StandardMaterial3D.new()
		bm.albedo_color = Color(0.45, 0.4, 0.32)
		b.material_override = bm
		var x := rng.randf_range(-180.0, 180.0)
		var z := rng.randf_range(-180.0, 180.0)
		if Vector2(x, z).length() < 20.0:
			x += 30.0
		b.position = Vector3(x, h * 0.5, z)
		add_child(b)

func _build_targets() -> void:
	var spots := [
		Vector3(40, 1, -30), Vector3(-50, 1, 40), Vector3(80, 1, 60),
		Vector3(-70, 1, -50), Vector3(20, 1, 90), Vector3(-30, 1, -80),
		Vector3(100, 1, -20), Vector3(-90, 1, 10)
	]
	if objectives:
		objectives.spawn_targets(self, spots)
