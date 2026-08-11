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
	if database.missions.is_empty():
		database._register_defaults()
	debief = DebriefSystem.new()
	debief.name = "DebriefSystem"
	add_child(debief)
	scenario = ScenarioManager.new()
	scenario.name = "ScenarioManager"
	add_child(scenario)
	print("MissionManager ready")

func get_database() -> MissionDatabase:
	if database == null:
		database = MissionDatabase.new()
		add_child(database)
		database._register_defaults()
	elif database.missions.is_empty():
		database._register_defaults()
	return database

func start_mission(mission: Mission) -> void:
	if mission == null:
		return
	active = mission
	running = true
	start_time = Time.get_ticks_msec() / 1000.0
	last_summary = {}
	if debrief:
		debief.start_tracking()
	if scenario:
		scenario.apply_scenario(mission.scenario_id)
	if typeof(GameState) != TYPE_NIL:
		GameState.reset_run()
		GameState.set_map(mission.map_id)
	mission_started.emit(mission)
	print("Mission started: ", mission.title)
	get_tree().change_scene_to_file(mission.scene_path)

func start_mission_by_id(id: String) -> void:
	var m = get_database().get_mission(id)
	if m:
		start_mission(m)

func update_telemetry(t: Dictionary) -> void:
	if running and debrief:
		debief.update_from_telemetry(t)

func notify_targets_cleared(score: int, hits: int, total: int) -> void:
	if running and active:
		_finish(true, score, hits, total, "")

func notify_time_expired(score: int, hits: int, total: int) -> void:
	if running and active:
		_finish(false, score, hits, total, "Time expired")

func abandon() -> void:
	running = false
	active = null

func _finish(success: bool, score: int, hits: int, total: int, fail_reason: String) -> void:
	running = false
	var elapsed = (Time.get_ticks_msec() / 1000.0) - start_time
	var summary = {
		"success": success,
		"mission_id": active.id if active else "",
		"title": active.title if active else "",
		"score": score,
		"hits": hits,
		"total_targets": total,
		"time_sec": elapsed,
		"fail_reason": fail_reason,
		"peak_speed": 0.0
	}
	if debrief:
		var d = debrief.stop_and_summarize(score, hits, total)
		summary["peak_speed"] = d.get("peak_speed", 0.0)
	last_summary = summary
	active = null
	if success:
		mission_completed.emit(summary)
	else:
		mission_failed.emit(fail_reason)
	if typeof(GameState) != TYPE_NIL:
		GameState.score = score
	get_tree().change_scene_to_file("res://scenes/ui/MissionComplete.tscn")

func has_active_mission() -> bool:
	return running and active != null

func get_active() -> Mission:
	return active

func get_time_remaining() -> float:
	if active == null or active.time_limit_sec <= 0.0:
		return -1.0
	return maxf(0.0, active.time_limit_sec - ((Time.get_ticks_msec() / 1000.0) - start_time))
