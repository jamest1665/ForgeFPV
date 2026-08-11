# AquaticVehicle.gd
# Node3D flood/littoral trainer — FlightModel + WaterPhysicsManager + optional config
extends Node3D
class_name AquaticVehicle

@export var config_id: String = "flood_low"
@export var spawn_height: float = 8.0

var model: FlightModel
var water: WaterPhysicsManager
var config: AquaticDroneConfig
var body: MeshInstance3D
var cam: Camera3D
var fleet: Dictionary = {}

func _ready() -> void:
	fleet = AquaticDroneConfig.make_default_fleet()
	config = fleet.get(config_id, fleet["flood_low"])
	model = FlightModel.new()
	config.apply_to_flight_model(model)
	model.reset(global_position if global_position.y > 1.0 else Vector3(0, spawn_height, 0))
	_ensure_water()
	_build_visual()
	_build_camera()
	print("AquaticVehicle ready config=", config.display_name)

func _ensure_water() -> void:
	# Prefer a WaterPhysicsManager already in the scene
	var parent := get_parent()
	if parent and parent.has_node("WaterPhysicsManager"):
		water = parent.get_node("WaterPhysicsManager")
		return
	if get_tree().current_scene:
		var found = get_tree().current_scene.find_child("WaterPhysicsManager", true, false)
		if found:
			water = found
			return
	water = WaterPhysicsManager.new()
	water.name = "WaterPhysicsManager"
	water.set_flood_flow()
	if parent:
		parent.add_child(water)
	else:
		add_child(water)

func _build_visual() -> void:
	body = MeshInstance3D.new()
	body.name = "Body"
	var box := BoxMesh.new()
	box.size = Vector3(0.55, 0.12, 0.6)
	body.mesh = box
	var mat := StandardMaterial3D.new()
	mat.albedo_color = config.body_color if config else Color(0.2, 0.55, 0.95)
	body.material_override = mat
	add_child(body)
	# simple floats / skids
	for x in [-0.28, 0.28]:
		var skid := MeshInstance3D.new()
		var sbox := BoxMesh.new()
		sbox.size = Vector3(0.08, 0.05, 0.5)
		skid.mesh = sbox
		skid.position = Vector3(x, -0.1, 0)
		var sm := StandardMaterial3D.new()
		sm.albedo_color = Color(0.15, 0.15, 0.18)
		skid.material_override = sm
		add_child(skid)

func _build_camera() -> void:
	cam = Camera3D.new()
	cam.name = "FPVCamera"
	cam.current = true
	cam.fov = 100.0
	cam.position = Vector3(0, 0.08, 0.15)
	add_child(cam)

func set_config_id(id: String) -> void:
	if fleet.is_empty():
		fleet = AquaticDroneConfig.make_default_fleet()
	if not fleet.has(id):
		return
	config_id = id
	config = fleet[id]
	if model:
		config.apply_to_flight_model(model)
	if body and body.material_override is StandardMaterial3D:
		(body.material_override as StandardMaterial3D).albedo_color = config.body_color

func _physics_process(delta: float) -> void:
	if model == null:
		return
	model.read_input(delta)
	# Near-water control authority boost
	if water and config and water.is_near_water(model.pos, 4.0):
		model.turn_rate = config.turn_rate * config.low_alt_boost
	elif config:
		model.turn_rate = config.turn_rate
	model.step(delta)
	if water:
		water.apply_to_flight_model(model, delta, config)
	global_position = model.pos
	rotation = model.get_rotation()

func get_telemetry() -> Dictionary:
	var t := model.get_telemetry() if model else {}
	if water and model:
		t.merge(water.get_telemetry_at(model.pos))
	t["config_id"] = config_id
	t["config_name"] = config.display_name if config else ""
	return t

func get_flight_model() -> FlightModel:
	return model

func get_water_manager() -> WaterPhysicsManager:
	return water
