# FlightModel.gd
# Shared rate-mode FPV flight dynamics for ForgeFPV
# Phase 1: input reads keyboard + gamepad/joy; step() dynamics unchanged from prior baseline.
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

func _axis_from_keys() -> Vector4:
	# returns pitch, roll, yaw, throttle_delta_intent (-1..1 throttle stick analog via keys)
	var pitch_in := 0.0
	var roll_in := 0.0
	var yaw_in := 0.0
	var thr_in := 0.0
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
		thr_in = 1.0
	elif Input.is_physical_key_pressed(KEY_CTRL):
		thr_in = -1.0
	return Vector4(pitch_in, roll_in, yaw_in, thr_in)

func _axis_from_joy() -> Vector4:
	if typeof(PilotSettings) != TYPE_NIL and not PilotSettings.use_gamepad:
		return Vector4.ZERO
	# Joy axis conventions: left stick X=roll, Y=pitch; right X=yaw; triggers or right Y=throttle
	var pitch_j := Input.get_joy_axis(0, JOY_AXIS_LEFT_Y)
	var roll_j := Input.get_joy_axis(0, JOY_AXIS_LEFT_X)
	var yaw_j := Input.get_joy_axis(0, JOY_AXIS_RIGHT_X)
	var thr_j := -Input.get_joy_axis(0, JOY_AXIS_RIGHT_Y)  # up on stick = positive throttle
	# Also support triggers if present
	var lt := Input.get_joy_axis(0, JOY_AXIS_TRIGGER_LEFT)
	var rt := Input.get_joy_axis(0, JOY_AXIS_TRIGGER_RIGHT)
	if rt > 0.05 or lt > 0.05:
		thr_j = rt - lt
	return Vector4(pitch_j, roll_j, yaw_j, thr_j)

func read_input(delta: float) -> void:
	var keys := _axis_from_keys()
	var joy := _axis_from_joy()
	# Prefer stronger magnitude per axis (keyboard or stick)
	var pitch_in := keys.x if absf(keys.x) > absf(joy.x) else joy.x
	var roll_in := keys.y if absf(keys.y) > absf(joy.y) else joy.y
	var yaw_in := keys.z if absf(keys.z) > absf(joy.z) else joy.z
	var thr_in := keys.w if absf(keys.w) > absf(joy.w) else joy.w

	var rp := 1.0
	var rr := 1.0
	var ry := 1.0
	var inv_p := false
	var inv_r := false
	var inv_y := false
	var inv_t := false
	if typeof(PilotSettings) != TYPE_NIL:
		pitch_in = PilotSettings.shape_axis(pitch_in, PilotSettings.rate_pitch, PilotSettings.invert_pitch)
		roll_in = PilotSettings.shape_axis(roll_in, PilotSettings.rate_roll, PilotSettings.invert_roll)
		yaw_in = PilotSettings.shape_axis(yaw_in, PilotSettings.rate_yaw, PilotSettings.invert_yaw)
		if PilotSettings.invert_throttle:
			thr_in = -thr_in
		rp = PilotSettings.rate_pitch
		rr = PilotSettings.rate_roll
		ry = PilotSettings.rate_yaw
	else:
		var expo := 0.4
		pitch_in = pitch_in * (expo + (1.0 - expo) * absf(pitch_in))
		roll_in = roll_in * (expo + (1.0 - expo) * absf(roll_in))

	pitch = clampf(pitch + pitch_in * turn_rate * delta * rp, -1.2, 1.2)
	roll = clampf(roll + roll_in * turn_rate * delta * rr, -1.2, 1.2)
	yaw += yaw_in * turn_rate * 0.85 * delta * ry

	if absf(thr_in) > 0.02:
		throttle = clampf(throttle + thr_in * delta * 1.5, 0.0, 1.0)
	elif absf(keys.w) < 0.01 and absf(joy.w) < 0.08:
		# only settle to hover when no stick/key throttle command
		throttle = move_toward(throttle, hover_throttle, delta * 0.4)

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
