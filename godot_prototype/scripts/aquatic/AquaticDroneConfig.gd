# AquaticDroneConfig.gd
# Flood / littoral trainer airframe profiles for ForgeFPV aquatic maps
class_name AquaticDroneConfig
extends Resource

@export var id: String = "flood_low"
@export var display_name: String = "Flood Low-Alt"
@export var mass: float = 1.05
@export var max_speed: float = 36.0
@export var accel: float = 48.0
@export var air_drag: float = 2.0
@export var water_drag: float = 6.5
@export var turn_rate: float = 2.3
@export var battery_drain: float = 3.6
@export var body_color: Color = Color(0.2, 0.55, 0.95)
@export var role: String = "aquatic_trainer"

# Water interaction
@export var buoyancy: float = 14.0          # upward accel when submerged
@export var max_safe_depth: float = 0.8     # meters under surface before hard recovery
@export var spray_threshold_speed: float = 12.0
@export var low_alt_boost: float = 1.15     # slight control authority near water
@export var hull_clearance: float = 0.35    # preferred hover height above surface

func apply_to_flight_model(m: FlightModel) -> void:
	m.max_speed = max_speed
	m.accel = accel
	m.drag = air_drag
	m.turn_rate = turn_rate
	m.battery_drain = battery_drain
	m.min_alt = hull_clearance

static func make_default_fleet() -> Dictionary:
	var fleet: Dictionary = {}
	fleet["flood_low"] = _mk(
		"flood_low", "Flood Low-Alt", 36.0, 48.0, 2.0, 6.5, 2.3, 3.6,
		Color(0.2, 0.55, 0.95), 14.0, 0.8, 0.35
	)
	fleet["flood_sprint"] = _mk(
		"flood_sprint", "Flood Sprint", 42.0, 56.0, 1.8, 5.5, 2.6, 4.0,
		Color(0.15, 0.7, 0.9), 12.0, 0.6, 0.4
	)
	fleet["littoral_recon"] = _mk(
		"littoral_recon", "Littoral Recon", 32.0, 44.0, 1.7, 5.0, 2.1, 2.8,
		Color(0.3, 0.65, 0.55), 16.0, 1.0, 0.5
	)
	fleet["debris_agile"] = _mk(
		"debris_agile", "Debris Agile", 34.0, 52.0, 2.2, 7.0, 2.8, 3.8,
		Color(0.25, 0.45, 0.85), 13.0, 0.5, 0.3
	)
	return fleet

static func _mk(
		id: String, name: String, spd: float, acc: float, adrag: float, wdrag: float,
		turn: float, drain: float, col: Color, buoy: float, depth: float, clear: float
	) -> AquaticDroneConfig:
	var c := AquaticDroneConfig.new()
	c.id = id
	c.display_name = name
	c.max_speed = spd
	c.accel = acc
	c.air_drag = adrag
	c.water_drag = wdrag
	c.turn_rate = turn
	c.battery_drain = drain
	c.body_color = col
	c.buoyancy = buoy
	c.max_safe_depth = depth
	c.hull_clearance = clear
	return c
