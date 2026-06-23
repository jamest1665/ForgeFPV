# MissionManager.gd
# ForgeFPV - Simple Mission Manager

extends Node
class_name MissionManager

signal mission_started(mission: Mission)
signal mission_completed(success: bool)
signal progress_updated(text: String)

var current_mission: Mission = null
var current_kills: int = 0
var start_time: float = 0.0
var is_active: bool = false

func start_mission(mission: Mission):
	current_mission = mission
	current_kills = 0
	start_time = Time.get_unix_time_from_system()
	is_active = true
	emit_signal("mission_started", mission)

func register_kill():
	if not is_active or not current_mission: return
	current_kills += 1
	_check_completion()

func _process(delta: float):
	if is_active and current_mission:
		var elapsed = Time.get_unix_time_from_system() - start_time
		var progress = current_mission.get_progress_text(current_kills, elapsed)
		emit_signal("progress_updated", progress)
		if current_mission.is_complete(current_kills, elapsed):
			complete_mission(true)

func complete_mission(success: bool):
	is_active = false
	emit_signal("mission_completed", success)

func _check_completion():
	if current_mission and current_mission.is_complete(current_kills, Time.get_unix_time_from_system() - start_time):
		complete_mission(true)