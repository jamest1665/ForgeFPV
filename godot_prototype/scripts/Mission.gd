# Mission.gd
# ForgeFPV - Mission Data Class

extends Resource
class_name Mission

@export var id: String
@export var display_name: String
@export var description: String
@export var mission_type: String
@export var target_count: int = 0
@export var time_limit: float = 0.0
@export var success_conditions: Array[String] = []

func is_complete(current_kills: int, elapsed_time: float) -> bool:
	if mission_type == "strike" and target_count > 0:
		return current_kills >= target_count
	if mission_type == "loiter" and time_limit > 0:
		return elapsed_time >= time_limit
	return false

func get_progress_text(current_kills: int, elapsed_time: float) -> String:
	if mission_type == "strike":
		return "Targets destroyed: %d / %d" % [current_kills, target_count]
	if mission_type == "loiter":
		return "Loiter time: %.0f / %.0f sec" % [elapsed_time, time_limit]
	return "Mission in progress"