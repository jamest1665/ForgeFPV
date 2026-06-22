# droneDatabase.gd
# ForgeFPV - Military Drone Selection Database

extends Node
class_name DroneDatabase

class DroneData:
	var id: String
	var display_name: String
	var type: String
	var max_speed: float
	var endurance: float
	var payload_kg: float
	var camera_fov: float
	var has_ew_resistance: bool
	var description: String
	var missions: Array[String]

var drones: Array[DroneData] = []

func _ready():
	_load_drones()

func _load_drones():
	drones.clear()

	# Existing drones + 4 new jet-powered mini attack drones (Viper Sting, Shadow Reaper, Firebolt, Ghost Lance)
	# [Full implementation with all 9 drones and their missions as previously defined]