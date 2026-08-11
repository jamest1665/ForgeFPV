# MissionDatabase.gd — built-in Academy mission catalog
extends Node
class_name MissionDatabase

var missions: Dictionary = {}  # id -> Mission
var ordered_ids: Array = []

func _ready() -> void:
	_register_defaults()
	print("MissionDatabase: %d missions" % missions.size())

func _register_defaults() -> void:
	_add("donbas_basic", "Donbas — Basic Strikes", "Hit all field targets. Build throttle and aiming fundamentals.",
		"donbas", "res://scenes/maps/DonbasTest.tscn", "target_practice", 8, 0.0, 1,
		"Stay low, clear the red targets. ESC pauses.")
	_add("donbas_timed", "Donbas — Timed Run", "Clear all targets under 3 minutes.",
		"donbas", "res://scenes/maps/DonbasTest.tscn", "timed_strike", 8, 180.0, 2,
		"Clock is running. Prioritize nearest targets.")
	_add("urban_canyon", "Urban — Canyon Clearing", "Navigate buildings and eliminate targets.",
		"urban", "res://scenes/maps/UrbanTest.tscn", "target_practice", 6, 0.0, 2,
		"Tight spaces. Control yaw carefully.")
	_add("aquatic_flood", "Aquatic — Flood Search", "Low-alt over water. Hit debris-zone targets.",
		"aquatic", "res://scenes/maps/aquatic_flood/AquaticTest.tscn", "target_practice", 6, 0.0, 2,
		"Do not submerge. Watch the water state on HUD.")
	_add("taiwan_littoral", "Taiwan — Littoral Sweep", "Coastal + inland target sweep.",
		"taiwan", "res://scenes/maps/global_06_taiwan_littoral/TaiwanTest.tscn", "target_practice", 7, 0.0, 2,
		"Coastal wind. Watch the shoreline.")
	_add("arctic_patrol", "Arctic — Ice Patrol", "Cold-weather field targets under stiff wind.",
		"arctic", "res://scenes/maps/arctic/ArcticTest.tscn", "target_practice", 6, 0.0, 2,
		"High wind. Battery drains faster in practice profiles.")
	_add("border_recon", "Border — Canyon Recon", "Desert canyon target acquisition.",
		"border", "res://scenes/maps/border/BorderTest.tscn", "target_practice", 7, 0.0, 1,
		"Open terrain. Use altitude for spotting.")
	_add("laport_yard", "LA Port — Yard Sweep", "Container-yard target clearing.",
		"laport", "res://scenes/maps/la_port/LAPortTest.tscn", "target_practice", 8, 0.0, 2,
		"Obstacles dense. Roll/yaw discipline required.")
	_add("urban_flank", "Urban — Flanking Drill", "Clear targets; treat buildings as cover routes.",
		"urban", "res://scenes/maps/UrbanTest.tscn", "flanking", 6, 240.0, 3,
		"Scenario: flanking. Approach from off-axis when possible.")

func _add(id: String, title: String, desc: String, map_id: String, scene: String,
		scenario: String, targets: int, time_limit: float, diff: int, notes: String) -> void:
	var m := Mission.new()
	m.id = id
	m.title = title
	m.description = desc
	m.map_id = map_id
	m.scene_path = scene
	m.scenario_id = scenario
	m.target_count = targets
	m.time_limit_sec = time_limit
	m.difficulty = diff
	m.briefing_notes = notes
	missions[id] = m
	ordered_ids.append(id)

func get_mission(id: String) -> Mission:
	return missions.get(id, null)

func list_missions() -> Array:
	var out: Array = []
	for id in ordered_ids:
		out.append(missions[id])
	return out

func list_for_map(map_id: String) -> Array:
	var out: Array = []
	for id in ordered_ids:
		var m: Mission = missions[id]
		if m.map_id == map_id:
			out.append(m)
	return out
