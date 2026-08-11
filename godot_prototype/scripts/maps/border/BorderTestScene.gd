# BorderTestScene.gd — southern border training on BaseTrainingScene
extends BaseTrainingScene

func _init() -> void:
	map_name = "BORDER"
	wind_preset = "field"
	weather_preset = "clear"
	spawn_height = 14.0
	body_color = Color(0.85, 0.45, 0.2)

func _build_world() -> void:
	var ground := MeshInstance3D.new()
	var plane := PlaneMesh.new()
	plane.size = Vector2(480, 480)
	ground.mesh = plane
	var mat := StandardMaterial3D.new()
	mat.albedo_color = Color(0.55, 0.42, 0.28)
	ground.material_override = mat
	add_child(ground)

	var light := DirectionalLight3D.new()
	light.light_energy = 1.5
	light.rotation_degrees = Vector3(-60, 25, 0)
	add_child(light)

	var rng := RandomNumberGenerator.new()
	rng.seed = 33
	for i in range(22):
		var rock := MeshInstance3D.new()
		var box := BoxMesh.new()
		var h := rng.randf_range(3.0, 14.0)
		box.size = Vector3(rng.randf_range(4.0, 12.0), h, rng.randf_range(4.0, 12.0))
		rock.mesh = box
		var rm := StandardMaterial3D.new()
		rm.albedo_color = Color(0.5, 0.38, 0.28)
		rock.material_override = rm
		var x := rng.randf_range(-170.0, 170.0)
		var z := rng.randf_range(-170.0, 170.0)
		if Vector2(x, z).length() < 18.0:
			x += 25.0
		rock.position = Vector3(x, h * 0.5, z)
		add_child(rock)

func _build_targets() -> void:
	var spots := [
		Vector3(40, 2, -35), Vector3(-50, 2, 40), Vector3(75, 2, 25),
		Vector3(-35, 2, -70), Vector3(15, 2, 90), Vector3(-90, 2, 20), Vector3(55, 2, -55)
	]
	if objectives:
		objectives.spawn_targets(self, spots)
