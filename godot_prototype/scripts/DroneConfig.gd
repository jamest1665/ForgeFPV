# DroneConfig.gd — airframe profile data
class_name DroneConfig
extends Resource

@export var id: String = "trainer_5inch"
@export var display_name: String = "Trainer 5-inch"
@export var mass: float = 1.0
@export var max_speed: float = 45.0
@export var accel: float = 55.0
@export var drag: float = 1.8
@export var turn_rate: float = 2.4
@export var battery_drain: float = 3.5
@export var body_color: Color = Color(0.95, 0.55, 0.1)
@export var role: String = "trainer"  # trainer, kamikaze, recon, interceptor

func apply_to_flight_model(m: FlightModel) -> void:
	m.max_speed = max_speed
	m.accel = accel
	m.drag = drag
	m.turn_rate = turn_rate
	m.battery_drain = battery_drain
