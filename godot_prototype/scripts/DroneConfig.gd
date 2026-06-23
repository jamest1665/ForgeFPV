# DroneConfig.gd
# ForgeFPV - Per-Drone Configuration & Application

extends Resource
class_name DroneConfig

@export var id: String
@export var display_name: String

@export var mass: float = 1.0
@export var inertia: Vector3 = Vector3(0.012, 0.012, 0.022)
@export var max_thrust_per_motor: float = 11.5
@export var drag_lin: float = 0.18
@export var drag_ang: float = 0.009
@export var camera_fov: float = 95.0
@export var ew_resistance: float = 0.0
@export var battery_drain_multiplier: float = 1.0

@export var default_missions: Array[String] = []

static func from_drone_data(data) -> DroneConfig:
	var config = DroneConfig.new()
	config.id = data.id
	config.display_name = data.display_name

	# Basic mapping (can be expanded)
	config.mass = 1.0
	config.max_thrust_per_motor = 12.0
	config.camera_fov = data.camera_fov
	config.ew_resistance = 0.5 if data.has_ew_resistance else 0.1

	return config

func apply_to_quad(quad):
	if not quad: return
	quad.mass = mass
	quad.max_thrust_per_motor = max_thrust_per_motor
	quad.drag_lin = drag_lin
	quad.drag_ang = drag_ang
	print("Applied config:", display_name)