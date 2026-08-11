# WaterPhysicsManager.gd
# Surface height, buoyancy, current, and near-water drag for flood / littoral training
extends Node
class_name WaterPhysicsManager

@export var surface_y: float = 0.0
@export var density: float = 1.0
@export var base_current: Vector3 = Vector3(0.8, 0.0, 0.3)
@export var current_turbulence: float = 0.4
@export var enabled: bool = true

var _time: float = 0.0

func _process(delta: float) -> void:
	_time += delta

func set_surface_height(y: float) -> void:
	surface_y = y

func get_surface_height_at(pos: Vector3) -> float:
	# Mild wave field — keeps low-alt flight interesting without full ocean sim
	var wave := sin(pos.x * 0.05 + _time * 1.2) * 0.15
	wave += cos(pos.z * 0.04 + _time * 0.9) * 0.1
	return surface_y + wave

func get_depth(pos: Vector3) -> float:
	# Positive when below surface
	return get_surface_height_at(pos) - pos.y

func is_near_water(pos: Vector3, band: float = 3.0) -> bool:
	return absf(pos.y - get_surface_height_at(pos)) <= band

func is_submerged(pos: Vector3) -> bool:
	return get_depth(pos) > 0.0

func get_current_at(pos: Vector3) -> Vector3:
	if not enabled:
		return Vector3.ZERO
	var turb := Vector3(
		sin(_time * 1.3 + pos.x * 0.02) * current_turbulence,
		0.0,
		cos(_time * 1.1 + pos.z * 0.02) * current_turbulence
	)
	return base_current + turb

## Returns force contribution (accel) to apply to FlightModel.vel this frame
func compute_water_accel(pos: Vector3, vel: Vector3, config: AquaticDroneConfig = null) -> Vector3:
	if not enabled:
		return Vector3.ZERO
	var depth := get_depth(pos)
	var accel := Vector3.ZERO
	var buoy := 14.0
	var water_drag := 6.5
	if config:
		buoy = config.buoyancy
		water_drag = config.water_drag

	# Buoyancy when under surface
	if depth > 0.0:
		var sub := clampf(depth / 1.5, 0.0, 1.0)
		accel.y += buoy * sub * density
		# Strong drag in water
		accel -= vel * water_drag * sub * delta_safe()
		# Current pushes the airframe
		accel += get_current_at(pos) * sub

elif depth > -2.5:
		# Near-surface spray zone — mild extra drag + slight upward cushion
		var near := 1.0 - clampf((-depth) / 2.5, 0.0, 1.0)
		accel.y += buoy * 0.15 * near
		accel -= vel * (water_drag * 0.2) * near * delta_safe()
		accel += get_current_at(pos) * 0.25 * near
	return accel

func delta_safe() -> float:
	# Used as a scale factor when callers integrate with their own delta
	return 1.0

## Apply water effects directly onto a FlightModel for one simulation step
func apply_to_flight_model(m: FlightModel, delta: float, config: AquaticDroneConfig = null) -> void:
	if not enabled or m == null:
		return
	var depth := get_depth(m.pos)
	var buoy := 14.0
	var water_drag := 6.5
	var clearance := 0.35
	if config:
		buoy = config.buoyancy
		water_drag = config.water_drag
		clearance = config.hull_clearance
		m.min_alt = get_surface_height_at(m.pos) + clearance

	if depth > 0.0:
		var sub := clampf(depth / 1.5, 0.0, 1.0)
		m.vel.y += buoy * sub * density * delta
		m.vel *= (1.0 - water_drag * sub * delta)
		m.vel += get_current_at(m.pos) * sub * delta
		# Hard floor recovery — pop back toward surface if too deep
		var max_depth := 0.8
		if config:
			max_depth = config.max_safe_depth
		if depth > max_depth:
			m.pos.y = get_surface_height_at(m.pos) - max_depth * 0.5
			m.vel.y = maxf(m.vel.y, 2.0)
	elif depth > -2.5:
		var near := 1.0 - clampf((-depth) / 2.5, 0.0, 1.0)
		m.vel.y += buoy * 0.12 * near * delta
		m.vel *= (1.0 - water_drag * 0.15 * near * delta)
		m.vel += get_current_at(m.pos) * 0.2 * near * delta

func set_calm() -> void:
	base_current = Vector3(0.2, 0, 0.1)
	current_turbulence = 0.15

func set_flood_flow() -> void:
	base_current = Vector3(1.5, 0, 0.6)
	current_turbulence = 0.55

func set_littoral_surf() -> void:
	base_current = Vector3(2.2, 0.05, 1.0)
	current_turbulence = 0.8

func get_telemetry_at(pos: Vector3) -> Dictionary:
	return {
		"surface_y": get_surface_height_at(pos),
		"depth": get_depth(pos),
		"submerged": is_submerged(pos),
		"near_water": is_near_water(pos),
		"current": get_current_at(pos),
	}
