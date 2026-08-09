# GameState.gd
# ForgeFPV - Global game state (Autoload)
extends Node

var selected_drone_config = null
var current_mission_id: String = ""
var selected_teams: int = 2
var selected_drones_per_team: int = 8
var selected_scenario: String = "ring_defense"
var score: int = 0
var objectives_completed: int = 0
var high_score: int = 0

func _ready():
	print("GameState: Ready")

func set_selected_drone(config) -> void:
	selected_drone_config = config

func clear_selected_drone() -> void:
	selected_drone_config = null

func set_team_selection(teams: int, drones: int) -> void:
	selected_teams = clamp(teams, 1, 5)
	selected_drones_per_team = clamp(drones, 1, 100)

func set_scenario(scenario_id: String) -> void:
	selected_scenario = scenario_id

func add_score(points: int) -> void:
	score += points
	if score > high_score:
		high_score = score

func get_score() -> int:
	return score

func complete_objective() -> void:
	objatives_completed += 1

func reset_run() -> void:
	score = 0
	objatives_completed = 0
	current_mission_id = ""

func get_run_summary() -> Dictionary:
	return {"score": score, "objectives": objectives_completed, "scenario": selected_scenario, "teams": selected_teams, "drones_per_team": selected_drones_per_team}
