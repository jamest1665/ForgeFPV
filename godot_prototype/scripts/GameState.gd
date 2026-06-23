# GameState.gd
# ForgeFPV - Global game state (Autoload)

extends Node

var selected_drone_config: DroneConfig = null
var current_mission: Mission = null

func set_selected_drone(config: DroneConfig):
	selected_drone_config = config
	print("GameState: Selected drone set to", config.display_name if config else "None")

func clear_selected_drone():
	selected_drone_config = null

func set_current_mission(mission: Mission):
	current_mission = mission

func clear_mission():
	current_mission = null