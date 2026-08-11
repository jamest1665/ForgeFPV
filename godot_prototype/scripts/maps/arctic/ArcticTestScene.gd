# ArcticTestScene.gd — high-north training on BaseTrainingScene
extends BaseTrainingScene

func _init() -> void:
	map_name = "ARCTIC"
	wind_preset = "arctic"
	weather_preset = "arctic"
	spawn_height = 12.0
	body_color = Color(0.7, 0.85, 1.0)

func _build_world() -> void:
	var ground := MeshInstance3D.new()
	var plane := PlaneMesh.new()
	plane.size = Vector2(500, 500)
	ground.mesh = plane
	var mat := StandardMaterial3D.new()
	mat.albedo_color = Color(0.82, 0.88, 0.92)
	ground.material_override = mat
	add_child(ground)

	var light := DirectionalLight3D.new()
	light.light_energy = 0.95
	light.rotation_degrees = Vector3(-35, 10, 0)
	add_child(light)

	var rng := RandomNumberGenerator.new()
	rng.seed = 99
	for i in range(15):
		var ice := MeshInstance3D.new()
		var box := BoxMesh.new()
		var h := rng.randf_range(1.5, 6.0)
		box.size = Vector3(rng.randf_range(5.0, 15.0), h, rng.randf_range(5.0, 15.0))
		ice.mesh = box
		var im := StandardMaterial3D.new()
		im.albedo_color = Color(0.75, 0.85, 0.95)
		ice.material_override = im
		ice.position = Vector3(rng.randf_range(-180.0, 180.0), h * 0.5, rng.randf_range(-180.0, 180.0))
		add_child(ice)

func _build_targets() -> void:
	var spots := [
		Vector3(35, 2, -25), Vector3(-45, 2, 30), Vector3(70, 2, 40),
		Vector3(-55, 2, -60), Vector3(20, 2, 85), Vector3(-80, 2, 15)
	]
	if objectives:
		objectives.spawn_targets(self, spots)
