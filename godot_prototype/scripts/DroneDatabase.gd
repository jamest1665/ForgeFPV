# DroneDatabase.gd — built-in trainer fleet profiles
extends Node

var drones: Dictionary = {}

func _ready() -> void:
	_register_defaults()
	print("DroneDatabase: %d profiles" % drones.size())

func _register_defaults() -> void:
	_add("trainer_5inch", "Trainer 5-inch", 45.0, 55.0, 1.8, 2.4, 3.5, Color(0.95, 0.55, 0.1), "trainer")
	_add("urban_racer", "Urban Racer", 50.0, 62.0, 1.6, 2.8, 4.0, Color(0.15, 0.85, 0.35), "trainer")
	_add("coastal_long", "Coastal Long-Range", 40.0, 48.0, 1.5, 2.0, 2.8, Color(0.9, 0.75, 0.15), "recon")
	_add("arctic_stable", "Arctic Stable", 38.0, 50.0, 2.0, 2.1, 4.2, Color(0.7, 0.85, 1.0), "trainer")
	_add("port_agile", "Port Agile", 42.0, 58.0, 1.9, 2.6, 3.8, Color(0.2, 0.7, 0.9), "trainer")
	_add("flood_low", "Flood Low-Alt", 36.0, 48.0, 2.2, 2.3, 3.6, Color(0.2, 0.55, 0.95), "trainer")
	_add("border_scout", "Border Scout", 44.0, 54.0, 1.9, 2.4, 3.5, Color(0.85, 0.45, 0.2), "recon")

func _add(id: String, name: String, spd: float, acc: float, drag: float, turn: float, drain: float, col: Color, role: String) -> void:
	var c := DroneConfig.new()
	c.id = id
	c.display_name = name
	c.max_speed = spd
	c.accel = acc
	c.drag = drag
	c.turn_rate = turn
	c.battery_drain = drain
	c.body_color = col
	c.role = role
	drones[id] = c

func get_drone(id: String) -> DroneConfig:
	if drones.has(id):
		return drones[id]
	return drones.get("trainer_5inch", null)

func list_ids() -> Array:
	return drones.keys()
