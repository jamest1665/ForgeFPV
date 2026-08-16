# DonbasTestScene.gd — Phase 1 showcase art pass (field + ruins, denser props)
extends BaseTrainingScene

func _init() -> void:
	map_name = "DONBAS"
	wind_preset = "field"
	weather_preset = "clear"
	spawn_height = 15.0
	body_color = Color(0.95, 0.55, 0.1)

func _build_world() -> void:
	_build_ground()
	_build_sky_light()
	_build_road()
	_build_structures()
	_build_props()

func _build_ground() -> void:
	var ground := MeshInstance3D.new()
	var plane := PlaneMesh.new()
	plane.size = Vector2(520, 520)
	ground.mesh = plane
	var mat := StandardMaterial3D.new()
	mat.albedo_color = Color(0.38, 0.34, 0.22)
	mat.roughness = 0.92
	ground.material_override = mat
	add_child(ground)

	# darker soil patches
	var rng := RandomNumberGenerator.new()
	rng.seed = 11
	for i in range(12):
		var patch := MeshInstance3D.new()
		var pmesh := PlaneMesh.new()
		var s := rng.randf_range(18.0, 40.0)
		pmesh.size = Vector2(s, s)
		patch.mesh = pmesh
		var pm := StandardMaterial3D.new()
		pm.albedo_color = Color(0.32, 0.28, 0.18).lerp(Color(0.45, 0.4, 0.28), rng.randf())
		pm.roughness = 0.95
		patch.material_override = pm
		patch.position = Vector3(rng.randf_range(-160, 160), 0.02, rng.randf_range(-160, 160))
		add_child(patch)

func _build_sky_light() -> void:
	var light := DirectionalLight3D.new()
	light.name = "Sun"
	light.light_energy = 1.45
	light.light_color = Color(1.0, 0.97, 0.92)
	light.shadow_enabled = true
	light.shadow_opacity = 0.85
	light.rotation_degrees = Vector3(-52, 35, 0)
	add_child(light)

	var fill := OmniLight3D.new()
	fill.light_energy = 0.2
	fill.light_color = Color(0.55, 0.62, 0.75)
	fill.omni_range = 250.0
	fill.position = Vector3(0, 60, 0)
	add_child(fill)

	var env_node := WorldEnvironment.new()
	var env := Environment.new()
	env.background_mode = Environment.BG_COLOR
	env.background_color = Color(0.52, 0.62, 0.78)
	env.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	env.ambient_light_color = Color(0.55, 0.58, 0.62)
	env.ambient_light_energy = 0.45
	env.tonemap_mode = Environment.TONE_MAPPER_ACES
	env.tonemap_exposure = 1.05
	env.ssao_enabled = true
	env.ssao_radius = 1.2
	env.glow_enabled = true
	env.glow_intensity = 0.25
	env_node.environment = env
	add_child(env_node)

func _build_road() -> void:
	var road := MeshInstance3D.new()
	var box := BoxMesh.new()
	box.size = Vector3(14.0, 0.08, 320.0)
	road.mesh = box
	var mat := StandardMaterial3D.new()
	mat.albedo_color = Color(0.22, 0.22, 0.24)
	mat.roughness = 0.85
	road.material_override = mat
	road.position = Vector3(0, 0.04, 0)
	add_child(road)

	# cross road
	var road2 := MeshInstance3D.new()
	var box2 := BoxMesh.new()
	box2.size = Vector3(260.0, 0.07, 10.0)
	road2.mesh = box2
	road2.material_override = mat
	road2.position = Vector3(0, 0.035, 40)
	add_child(road2)

func _mat_concrete(rng: RandomNumberGenerator) -> StandardMaterial3D:
	var m := StandardMaterial3D.new()
	m.albedo_color = Color(
		rng.randf_range(0.35, 0.5),
		rng.randf_range(0.32, 0.45),
		rng.randf_range(0.28, 0.4)
	)
	m.roughness = rng.randf_range(0.75, 0.95)
	return m

func _mat_brick(rng: RandomNumberGenerator) -> StandardMaterial3D:
	var m := StandardMaterial3D.new()
	m.albedo_color = Color(
		rng.randf_range(0.42, 0.58),
		rng.randf_range(0.28, 0.38),
		rng.randf_range(0.22, 0.3)
	)
	m.roughness = 0.9
	return m

func _build_structures() -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = 42
	for i in range(28):
		var h := rng.randf_range(2.5, 11.0)
		var w := rng.randf_range(4.0, 12.0)
		var d := rng.randf_range(4.0, 12.0)
		var b := MeshInstance3D.new()
		var box := BoxMesh.new()
		box.size = Vector3(w, h, d)
		b.mesh = box
		b.material_override = _mat_brick(rng) if rng.randf() > 0.45 else _mat_concrete(rng)
		var x := rng.randf_range(-190.0, 190.0)
		var z := rng.randf_range(-190.0, 190.0)
		if Vector2(x, z).length() < 22.0:
			x += 35.0
		# keep clear of main road band
		if absf(x) < 10.0:
			x = 18.0 if x >= 0.0 else -18.0
		b.position = Vector3(x, h * 0.5, z)
		add_child(b)

		# ruined top chunk offset
		if rng.randf() > 0.55:
			var ruin := MeshInstance3D.new()
			var rbox := BoxMesh.new()
			rbox.size = Vector3(w * 0.4, rng.randf_range(0.8, 2.2), d * 0.35)
			ruin.mesh = rbox
			ruin.material_override = _mat_concrete(rng)
			ruin.position = Vector3(x + rng.randf_range(-1, 1), h + 0.5, z + rng.randf_range(-1, 1))
			ruin.rotation_degrees.y = rng.randf_range(-25, 25)
			add_child(ruin)

func _build_props() -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = 99
	# utility poles along road
	for i in range(-8, 9):
		var pole := MeshInstance3D.new()
		var cyl := CylinderMesh.new()
		cyl.top_radius = 0.12
		cyl.bottom_radius = 0.15
		cyl.height = 7.0
		pole.mesh = cyl
		var mat := StandardMaterial3D.new()
		mat.albedo_color = Color(0.25, 0.22, 0.18)
		pole.material_override = mat
		pole.position = Vector3(9.0, 3.5, i * 22.0)
		add_child(pole)

	# rubble piles near targets corridor
	for i in range(20):
		var rubble := MeshInstance3D.new()
		var box := BoxMesh.new()
		box.size = Vector3(rng.randf_range(1.0, 3.5), rng.randf_range(0.4, 1.4), rng.randf_range(1.0, 3.5))
		rubble.mesh = box
		var mat := StandardMaterial3D.new()
		mat.albedo_color = Color(0.4, 0.38, 0.34)
		mat.roughness = 1.0
		rubble.material_override = mat
		rubble.position = Vector3(rng.randf_range(-100, 100), box.size.y * 0.5, rng.randf_range(-100, 100))
		rubble.rotation_degrees = Vector3(rng.randf_range(-10, 10), rng.randf_range(0, 360), rng.randf_range(-8, 8))
		add_child(rubble)

func _build_targets() -> void:
	var spots := [
		Vector3(40, 1, -30), Vector3(-50, 1, 40), Vector3(80, 1, 60),
		Vector3(-70, 1, -50), Vector3(20, 1, 90), Vector3(-30, 1, -80),
		Vector3(100, 1, -20), Vector3(-90, 1, 10)
	]
	if objectives:
		objectives.spawn_targets(self, spots)
