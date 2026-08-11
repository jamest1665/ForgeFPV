# LAPortTestScene.gd — megaport training on BaseTrainingScene
extends BaseTrainingScene

func _init() -> void:
	map_name = "LA PORT"
	wind_preset = "urban"
	weather_preset = "overcast"
	spawn_height = 16.0
	body_color = Color(0.2, 0.7, 0.9)

func _build_world() -> void:
	var ground := MeshInstance3D.new()
	var plane := PlaneMesh.new()
	plane.size = Vector2(400, 400)
	ground.mesh = plane
	var mat := StandardMaterial3D.new()
	mat.albedo_color = Color(0.25, 0.25, 0.28)
	ground.material_override = mat
	add_child(ground)

	var light := DirectionalLight3D.new()
	light.light_energy = 1.3
	light.rotation_degrees = Vector3(-48, 35, 0)
	add_child(light)

	var rng := RandomNumberGenerator.new()
	rng.seed = 55
	for i in range(28):
		var b := MeshInstance3D.new()
		var box := BoxMesh.new()
		var h := rng.randf_range(6.0, 22.0)
		box.size = Vector3(rng.randf_range(6.0, 14.0), h, rng.randf_range(4.0, 10.0))
		b.mesh = box
		var bm := StandardMaterial3D.new()
		bm.albedo_color = Color(rng.randf_range(0.2, 0.5), rng.randf_range(0.25, 0.45), rng.randf_range(0.3, 0.55))
		b.material_override = bm
		var x := rng.randf_range(-140.0, 140.0)
		var z := rng.randf_range(-140.0, 140.0)
		if Vector2(x, z).length() < 20.0:
			x += 30.0
		b.position = Vector3(x, h * 0.5, z)
		add_child(b)

func _build_targets() -> void:
	var spots := [
		Vector3(30, 2, -25), Vector3(-40, 2, 35), Vector3(65, 2, 40),
		Vector3(-55, 2, -45), Vector3(20, 2, 75), Vector3(-70, 2, 10),
		Vector3(85, 2, -30), Vector3(-20, 2, -80)
	]
	if objectives:
		objectives.spawn_targets(self, spots)
