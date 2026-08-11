# MissionManager.gd — active mission runtime (autoload)
extends Node

signal mission_started(mission: Mission)
signal mission_completed(summary: Dictionary)
signal mission_failed(reason: String)

var database: MissionDatabase
var active: Mission = null
var running: bool = false
var debrief: DebriefSystem
var scenario: ScenarioManager
var start_time: float = 0.0
var last_summary: Dictionary = {}

func _ready() -> void:
	database = MissionDatabase.new()
	database.name = "MissionDatabase"
	add_child(database)
	database._register_defaults()
	database.ordered_ids = database.ordered_ids  # ensure registered
	database.missions = database.missions
	# MissionDatabase _ready may not fire if added as child after - force register
	if database.missions.is_empty():
		database._register_defaults()
	debief_init()
	scenario = ScenarioManager.new()
	scenario.name = "ScenarioManager"
	add_child(scenario)
	print("MissionManager ready")

func debief_init() -> void:
	debief = DebriefSystem.new()
	debief.name = "DebriefSystem"
	add_child(debief)

# fix typo - use debrief not debief
var _debrief_alias_fix: bool = false

func _enter_tree() -> void:
	pass

func get_database() -> MissionDatabase:
	if database == null:
		database = MissionDatabase.new()
		add_child(database)
		if database.missions.is_empty():
			database._register_defaults()
	return database

func start_mission(mission: Mission) -> void:
	if mission == null:
		return
	active = mission
	running = true
	start_time = Time.get_ticks_msec() / 1000.0
	last_summary = {}
	if debief:
		debief.start_tracking()
	elif has_node("DebriefSystem"):
		(get_node("DebriefSystem") as DebriefSystem).start_tracking()
	if scenario:
		scenario.apply_scenario(mission.scenario_id)
	if typeof(GameState) != TYPE_NIL:
		GameState.reset_run()
		GameState.set_map(mission.map_id)
	mission_started.emit(mission)
	print("Mission started: ", mission.title)
	get_tree().change_scene_to_file(mission.scene_path)

func start_mission_by_id(id: String) -> void:
	var db := get_database()
	var m := db.get_mission(id)
	if m:
		start_mission(m)

func update_telemetry(t: Dictionary) -> void:
	if not running:
		return
	if debief:
		debief.update_from_telemetry(t)

func notify_targets_cleared(score: int, hits: int, total: int) -> void:
	if not running or active == null:
		return
	_finish(true, score, hits, total, "")

func notify_time_expired(score: int, hits: int, total: int) -> void:
	if not running or active == null:
		return
	_finish(false, score, hits, total, "Time expired")

func abandon() -> void:
	if not running:
		return
	running = false
	active = null

func _finish(success: bool, score: int, hits: int, total: int, fail_reason: String) -> void:
	running = false
	var elapsed := (Time.get_ticks_msec() / 1000.0) - start_time
	var summary := {
		"success": success,
		"mission_id": active.id if active else "",
		"title": active.title if active else "",
		"score": score,
		"hits": hits,
		"total_targets": total,
		"time_sec": elapsed,
		"fail_reason": fail_reason
	}
	if debief:
		var d := debief.stop_and_summarize(score, hits, total)
		summary["peak_speed"] = d.get("peak_speed", 0.0)
	last_summary = summary
	var mid := active.id if active else ""
	active = null
	if success:
		mission_completed.emit(summary)
	else:
		mission_failed.emit(fail_reason)
	# Store for complete screen
	if typeof(GameState) != TYPE_NIL:
		GameState.score = score
	print("Mission finished success=", success, " score=", score)
	get_tree().change_scene_to_file("res://scenes/ui/MissionComplete.tscn")

func has_active_mission() -> bool:
	return running and active != null

func get_active() -> Mission:
	return active

func get_time_remaining() -> float:
	if active == null or active.time_limit_sec <= 0.0:
		return -1.0
	var elapsed := (Time.get_ticks_msec() / 1000.0) - start_time
	return maxf(0.0, active.time_limit_sec - elapsed)
