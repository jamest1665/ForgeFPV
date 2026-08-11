# AquaticTestScene.gd
# Flood training map — AquaticVehicle + WaterPhysicsManager + targets + HUD
extends Node3D

var water: WaterPhysicsManager
var vehicle: AquaticVehicle
var hud: Label
var targets: Array = []
var hit_ids: Dictionary = {}
var score: int = 0

func _ready() -> void:
	_build_world()
	_build_water()
	_build_vehicle()
	_build_targets()
	_build_hud()
	print("Aquatic Flood training ready (WaterPhysics + AquaticVehicle)")

func _build_world() -> void:
	var water_mesh := MeshInstance3D.new()
	water_mesh.name = "WaterSurface"
	var plane := PlaneMesh.new()
	plane.size = Vector2(400, 400)
	water_mesh.mesh = plane
	var mat := StandardMaterial3D.new()
	mat.albedo_color = Color(0.12, 0.28, 0.42)
	mat.roughness = 0.15
	mat.metallic = 0.1
	water_mesh.material_override = mat
	water_mesh.position.y = 0.0
	add_child(water_mesh)

	var light := DirectionalLight3D.new()
	light.light_energy = 1.2
	light.shadow_enabled = true
	light.rotation_degrees = Vector3(-50, 40, 0)
	add_child(light)

	var rng := RandomNumberGenerator.new()
	rng.seed = 11
	for i in range(14):
		var debris := MeshInstance3D.new()
		var box := BoxMesh.new()
		box.size = Vector3(rng.randf_range(2.0, 6.0), rng.randf_range(1.0, 3.0), rng.randf_range(2.0, 6.0))
		debris.mesh = box
		var dm := StandardMaterial3D.new()
		dm.albedo_color = Color(0.35, 0.3, 0.22)
		debris.material_override = dm
		var x := rng.randf_range(-150.0, 150.0)
		var z := rng.randf_range(-150.0, 150.0)
		if Vector2(x, z).length() < 18.0:
			x += 25.0
		debris.position = Vector3(x, 1.0, z)
		add_child(debris)

func _build_water() -> void:
	water = WaterPhysicsManager.new()
	water.name = "WaterPhysicsManager"
	water.surface_y = 0.0
	water.set_flood_flow()
	add_child(water)

func _build_vehicle() -> void:
	vehicle = AquaticVehicle.new()
	vehicle.name = "AquaticVehicle"
	vehicle.config_id = "flood_low"
	vehicle.spawn_height = 8.0
	vehicle.position = Vector3(0, 8, 0)
	add_child(vehicle)

func _build_targets() -> void:
	var spots := [
		Vector3(30, 2, -20), Vector3(-40, 2, 25), Vector3(55, 2, 45),
		Vector3(-25, 2, -55), Vector3(70, 2, -10), Vector3(-60, 2, 5)
	]
	for i in range(spots.size()):
		var t := MeshInstance3D.new()
		var box := BoxMesh.new()
		box.size = Vector3(2.2, 2.0, 2.2)
		t.mesh = box
		var mat := StandardMaterial3D.new()
		mat.albedo_color = Color(0.9, 0.2, 0.1)
		mat.emission_enabled = true
		mat.emission = Color(0.7, 0.1, 0.05)
		mat.emission_energy_multiplier = 0.9
		t.material_override = mat
		t.position = spots[i]
		t.set_meta("tid", i)
		add_child(t)
		targets.append(t)

func _build_hud() -> void:
	var layer := CanvasLayer.new()
	add_child(layer)
	hud = Label.new()
	hud.position = Vector2(16, 12)
	hud.add_theme_font_size_override("font_size", 18)
	layer.add_child(hud)
	var help := Label.new()
	help.position = Vector2(16, 680)
	help.add_theme_font_size_override("font_size", 14)
	help.text = "Aquatic Flood · WASD Q/E Space/Ctrl · ESC menu · Stay above water · Hit red targets"
	layer.add_child(help)

func _process(_delta: float) -> void:
	_check_targets()
	_update_hud()
	if Input.is_key_pressed(KEY_ESCAPE):
		get_tree().change_scene_to_file("res://scenes/ui/MainMenu.tscn")

func _check_targets() -> void:
	if vehicle == null:
		return
	var p := vehicle.global_position
	for t in targets:
		if not is_instance_valid(t):
			continue
		var tid: int = t.get_meta("tid")
		if hit_ids.has(tid):
			continue
		if p.distance_to(t.position) < 4.0:
			hit_ids[tid] = true
			score += 100
			t.visible = false
			print("Aquatic target hit +100 score=", score)

func _update_hud() -> void:
	if hud == null or vehicle == null:
		return
	var t: Dictionary = vehicle.get_telemetry()
	var spd := float(t.get("speed", 0.0))
	var alt := float(t.get("alt", 0.0))
	var bat := float(t.get("battery", 0.0))
	var depth := float(t.get("depth", 0.0))
	var submerged := bool(t.get("submerged", false))
	var state := "WET" if submerged else ("NEAR" if depth > -2.5 else "AIR")
	hud.text = "AQUATIC  SPD %3.0f  ALT %3.0f  BAT %3.0f%%  %s  SCORE %d  TGT %d/%d" % [
		spd, alt, bat, state, score, hit_ids.size(), targets.size()
	]
