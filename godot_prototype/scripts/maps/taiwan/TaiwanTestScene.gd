# TaiwanTestScene.gd — littoral training on BaseTrainingScene
extends BaseTrainingScene

func _init() -> void:
	map_name = "TAIWAN"
	wind_preset = "coastal"
	weather_preset = "coastal"
	spawn_height = 20.0
	body_color = Color(0.9, 0.75, 0.15)

func _build_world() -> void:
	var ground := MeshInstance3D.new()
	var plane := PlaneMesh.new()
	plane.size = Vector2(450, 450)
	ground.mesh = plane
	var mat := StandardMaterial3D.new()
	mat.albedo_color = Color(0.3, 0.38, 0.28)
	ground.material_override = mat
	add_child(ground)

	var water := MeshInstance3D.new()
	var wp := PlaneMesh.new()
	wp.size = Vector2(200, 450)
	water.mesh = wp
	var wm := StandardMaterial3D.new()
	wm.albedo_color = Color(0.1, 0.25, 0.4)
	water.material_override = wm
	water.position = Vector3(200, -0.2, 0)
	add_child(water)

	var light := DirectionalLight3D.new()
	light.light_energy = 1.35
	light.rotation_degrees = Vector3(-52, 15, 0)
	add_child(light)

	var rng := RandomNumberGenerator.new()
	rng.seed = 66
	for i in range(20):
		var b := MeshInstance3D.new()
		var box := BoxMesh.new()
		var h := rng.randf_range(4.0, 18.0)
		box.size = Vector3(rng.randf_range(4.0, 10.0), h, rng.randf_range(4.0, 10.0))
		b.mesh = box
		var bm := StandardMaterial3D.new()
		bm.albedo_color = Color(0.4, 0.38, 0.35)
		b.material_override = bm
		b.position = Vector3(rng.randf_range(-100.0, 80.0), h * 0.5, rng.randf_range(-150.0, 150.0))
		add_child(b)

func _build_targets() -> void:
	var spots := [
		Vector3(40, 2, -30), Vector3(-30, 2, 40), Vector3(60, 2, 20),
		Vector3(-50, 2, -40), Vector3(20, 2, 80), Vector3(90, 2, -50), Vector3(-70, 2, 10)
	]
	if objectives:
		objectives.spawn_targets(self, spots)
