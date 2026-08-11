# UrbanTestScene.gd — canyon training on BaseTrainingScene
extends BaseTrainingScene

func _init() -> void:
	map_name = "URBAN"
	wind_preset = "urban"
	weather_preset = "overcast"
	spawn_height = 18.0
	body_color = Color(0.15, 0.85, 0.35)

func _build_world() -> void:
	var ground := MeshInstance3D.new()
	var plane := PlaneMesh.new()
	plane.size = Vector2(350, 350)
	ground.mesh = plane
	var mat := StandardMaterial3D.new()
	mat.albedo_color = Color(0.2, 0.2, 0.23)
	ground.material_override = mat
	add_child(ground)

	var light := DirectionalLight3D.new()
	light.light_energy = 1.25
	light.rotation_degrees = Vector3(-48, 20, 0)
	add_child(light)

	var rng := RandomNumberGenerator.new()
	rng.seed = 7
	for i in range(35):
		var b := MeshInstance3D.new()
		var box := BoxMesh.new()
		var h := rng.randf_range(10.0, 32.0)
		box.size = Vector3(rng.randf_range(5.0, 12.0), h, rng.randf_range(5.0, 12.0))
		b.mesh = box
		var bm := StandardMaterial3D.new()
		bm.albedo_color = Color(0.28, 0.28, 0.33)
		b.material_override = bm
		var x := rng.randf_range(-120.0, 120.0)
		var z := rng.randf_range(-120.0, 120.0)
		if Vector2(x, z).length() < 22.0:
			x += 28.0
		b.position = Vector3(x, h * 0.5, z)
		add_child(b)

func _build_targets() -> void:
	var spots := [
		Vector3(35, 2, -25), Vector3(-40, 2, 35), Vector3(55, 2, 50),
		Vector3(-60, 2, -40), Vector3(15, 2, 70), Vector3(-25, 2, -65)
	]
	if objectives:
		objectives.spawn_targets(self, spots)
