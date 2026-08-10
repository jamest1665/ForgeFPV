# FlightModel.gd
# Shared rate-mode FPV flight dynamics for ForgeFPV
class_name FlightModel
extends RefCounted

var pos: Vector3 = Vector3(0, 12, 0)
var vel: Vector3 = Vector3.ZERO
var yaw: float = 0.0
var pitch: float = 0.0
var roll: float = 0.0
var throttle: float = 0.0
var battery: float = 100.0

var max_speed: float = 45.0
var accel: float = 55.0
var drag: float = 1.8
var turn_rate: float = 2.4
var gravity: float = 9.8
var battery_drain: float = 3.5
var min_alt: float = 1.0
var hover_throttle: float = 0.35

var wind: Vector3 = Vector3.ZERO

func reset(spawn: Vector3 = Vector3(0, 12, 0)) -> void:
	pos = spawn
	vel = Vector3.ZERO
	yaw = 0.0
	pitch = 0.0
	roll = 0.0
	throttle = 0.0
	battery = 100.0

func read_input(delta: float) -> void:
	var pitch_in := 0.0
	var roll_in := 0.0
	var yaw_in := 0.0
	if Input.is_physical_key_pressed(KEY_W):
		pitch_in -= 1.0
	if Input.is_physical_key_pressed(KEY_S):
		pitch_in += 1.0
	if Input.is_physical_key_pressed(KEY_A):
		roll_in -= 1.0
	if Input.is_physical_key_pressed(KEY_D):
		roll_in += 1.0
	if Input.is_physical_key_pressed(KEY_Q):
		yaw_in -= 1.0
	if Input.is_physical_key_pressed(KEY_E):
		yaw_in += 1.0
	if Input.is_physical_key_pressed(KEY_SPACE):
		throttle = minf(throttle + delta * 1.5, 1.0)
	elif Input.is_physical_key_pressed(KEY_CTRL):
		throttle = maxf(throttle - delta * 1.5, 0.0)
	else:
		throttle = move_toward(throttle, hover_throttle, delta * 0.4)
	var expo := 0.4
	pitch = clampf(pitch + pitch_in * turn_rate * delta * (expo + (1.0 - expo) * absf(pitch_in)), -1.2, 1.2)
	roll = clampf(roll + roll_in * turn_rate * delta * (expo + (1.0 - expo) * absf(roll_in)), -1.2, 1.2)
	yaw += yaw_in * turn_rate * 0.85 * delta

func step(delta: float) -> void:
	var forward := Vector3(-sin(yaw) * cos(pitch), sin(pitch), -cos(yaw) * cos(pitch)).normalized()
	vel += forward * (throttle * accel) * delta
	vel += wind * delta
	vel.y -= gravity * delta * (1.0 - throttle * 0.85)
	vel *= (1.0 - drag * delta)
	if vel.length() > max_speed:
		vel = vel.normalized() * max_speed
	pos += vel * delta
	if pos.y < min_alt:
		pos.y = min_alt
		vel.y = maxf(vel.y, 0.0)
		vel *= 0.7
	battery = maxf(0.0, battery - throttle * battery_drain * delta)
	if battery <= 0.0:
		throttle = 0.0
		vel *= 0.98

func get_rotation() -> Vector3:
	return Vector3(pitch, yaw, -roll)

func get_speed() -> float:
	return vel.length()

func get_telemetry() -> Dictionary:
	return {
		"pos": pos,
		"speed": vel.length(),
		"alt": pos.y,
		"battery": battery,
		"throttle": throttle,
		"yaw": yaw,
		"pitch": pitch,
		"roll": roll
	}
