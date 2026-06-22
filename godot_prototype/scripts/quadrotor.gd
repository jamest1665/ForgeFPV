# quadrotor.gd
# ForgeFPV Godot 4 - Direct port of Python v0.2 Quadrotor class
# Purpose: High-fidelity 6DOF physics kernel that matches the validated Python reference.
# This is the single source of truth for flight dynamics in the Godot prototype.

extends Node3D
class_name Quadrotor

# =============================================================================
# PARAMETERS (tunable - match Python v0.2)
# =============================================================================
@export var mass: float = 1.0
@export var arm_length: float = 0.175
@export var max_thrust_per_motor: float = 11.5
@export var drag_lin: float = 0.18
@export var drag_ang: float = 0.009
@export var battery_capacity: float = 100.0
@export var thrust_discharge_rate: float = 0.075

# Inertia (diagonal)
var I: Vector3 = Vector3(0.012, 0.012, 0.022)

# Wind
@export var wind_base: Vector3 = Vector3(1.2, -0.8, 0.3)
@export var wind_turbulence: float = 0.6

# EW
@export var ew_jam_strength: float = 0.35
var ew_active: bool = false

# =============================================================================
# STATE (matches Python exactly)
# =============================================================================
var pos: Vector3 = Vector3(0, 0, 3.5)
var vel: Vector3 = Vector3.ZERO
var quat: Quaternion = Quaternion.IDENTITY
var omega: Vector3 = Vector3.ZERO          # body angular velocity rad/s

var battery: float = 100.0
var flight_time: float = 0.0
var score: int = 0
var target_pos: Vector3 = Vector3(14, 6, 2.8)
var last_engage_time: float = 0.0
var approach_quality: float = 1.0

# Physics timing
var physics_accumulator: float = 0.0
const PHYSICS_DT: float = 1.0 / 260.0

# =============================================================================
# QUATERNION HELPERS (Godot native + custom)
# =============================================================================
func quat_normalize(q: Quaternion) -> Quaternion:
	if q.length() < 0.0001:
		return Quaternion.IDENTITY
	return q.normalized()

func quat_to_basis(q: Quaternion) -> Basis:
	return Basis(q)

# =============================================================================
# MOTOR MIXING (X config - identical to Python v0.2)
# =============================================================================
func _motor_mixing(throttle: float, roll_cmd: float, pitch_cmd: float, yaw_cmd: float) -> Array[float]:
	var roll: float = roll_cmd * 4.2
	var pitch: float = pitch_cmd * 4.2
	var yaw: float = yaw_cmd * 2.1

	var m1: float = throttle + roll - pitch - yaw
	var m2: float = throttle - roll + pitch - yaw
	var m3: float = throttle + roll + pitch + yaw
	var m4: float = throttle - roll - pitch + yaw

	var thrusts: Array[float] = [
		clamp(m1, 0.0, 1.0) * max_thrust_per_motor,
		clamp(m2, 0.0, 1.0) * max_thrust_per_motor,
		clamp(m3, 0.0, 1.0) * max_thrust_per_motor,
		clamp(m4, 0.0, 1.0) * max_thrust_per_motor
	]
	return thrusts

# =============================================================================
# DYNAMICS (Newton-Euler port - matches Python exactly)
# =============================================================================
func _dynamics(dt: float, u: Array[float], current_wind: Vector3) -> Dictionary:
	var R: Basis = quat_to_basis(quat)

	# Thrust in body frame (Z up in our convention)
	var total_thrust_body: Vector3 = Vector3(0, 0, u[0] + u[1] + u[2] + u[3])
	var thrust_world: Vector3 = R * total_thrust_body

	var gravity: Vector3 = Vector3(0, 0, -9.80665 * mass)
	var effective_vel: Vector3 = vel - current_wind
	var drag: Vector3 = -drag_lin * effective_vel

	var force: Vector3 = thrust_world + gravity + drag
	var acc: Vector3 = force / mass

	# Torques
	var t1 = u[0]; var t2 = u[1]; var t3 = u[2]; var t4 = u[3]
	var tau: Vector3 = Vector3(
		arm_length * (t1 - t2 + t3 - t4) * 0.85,
		arm_length * (t1 + t2 - t3 - t4) * 0.85,
		3.5e-7 * (t1 - t2 - t3 + t4) * 850.0
	)
	tau -= drag_ang * omega

	# Euler equation
	var I_mat: Basis = Basis.from_scale(I)  # simplified diagonal
	var alpha: Vector3 = I_mat.inverse() * (tau - omega.cross(I_mat * omega))

	# Quaternion kinematics
	var omega_q: Quaternion = Quaternion(omega.x, omega.y, omega.z, 0.0)
	var dq: Quaternion = quat * omega_q * 0.5

	return {
		"acc": acc,
		"alpha": alpha,
		"dq": dq
	}

# =============================================================================
# MAIN STEP (fixed timestep integrator - same as Python)
# =============================================================================
func step(dt: float, u: Array[float]):
	# Wind with turbulence
	var wind: Vector3 = wind_base + Vector3(randf_range(-1,1), randf_range(-1,1), randf_range(-1,1)) * wind_turbulence * 0.6

	var d: Dictionary = _dynamics(dt, u, wind)

	vel += d.acc * dt
	pos += vel * dt
	omega += d.alpha * dt
	quat = quat_normalize(quat + d.dq * dt)

	# Ground
	if pos.z < 0.12:
		pos.z = 0.12
		vel.z = max(vel.z, 0.0) * 0.25

	# Battery
	var collective: float = (u[0] + u[1] + u[2] + u[3]) / (4.0 * max_thrust_per_motor)
	battery -= collective * thrust_discharge_rate * (dt * 60.0)
	battery = max(battery, 0.0)

	flight_time += dt
	last_engage_time += dt

# =============================================================================
# HIGH-LEVEL CONTROL INTERFACE (rate mode)
# =============================================================================
func get_control(throttle_cmd: float, roll_cmd: float, pitch_cmd: float, yaw_cmd: float) -> Array[float]:
	var kp: float = 11.5
	var err: Vector3 = Vector3(roll_cmd, pitch_cmd, yaw_cmd) - omega

	if ew_active:
		var jam: float = ew_jam_strength
		err += Vector3(randf_range(-1,1), randf_range(-1,1), randf_range(-1,1)) * jam * 2.5
		err *= (1.0 - jam * 0.6)

	var corrected_roll: float = clamp(roll_cmd + err.x * 0.08, -1.0, 1.0)
	var corrected_pitch: float = clamp(pitch_cmd + err.y * 0.08, -1.0, 1.0)
	var corrected_yaw: float = clamp(yaw_cmd + err.z * 0.08, -1.0, 1.0)

	return _motor_mixing(throttle_cmd, corrected_roll, corrected_pitch, corrected_yaw)

# =============================================================================
# ENGAGEMENT (identical logic to Python v0.2)
# =============================================================================
func try_engage_target(max_dist: float = 22.0, max_angle_deg: float = 16.0) -> bool:
	if last_engage_time < 0.7:
		return false

	var rel: Vector3 = target_pos - pos
	var dist: float = rel.length()
	if dist > max_dist or dist < 0.8:
		return false

	var R: Basis = quat_to_basis(quat)
	var rel_body: Vector3 = R.inverse() * rel
	if rel_body.x <= 0.8:
		return false

	var angle: float = rad_to_deg(atan2(rel_body.y, rel_body.x))
	if abs(angle) > max_angle_deg:
		return false

	# Approach quality
	var speed: float = vel.length()
	var rate_mag: float = omega.length()
	var quality: float = max(0.6, 1.0 - (speed * 0.04 + rate_mag * 0.8))
	var bonus: int = int(40 * quality)

	score += 100 + bonus
	approach_quality = quality
	last_engage_time = 0.0

	# Respawn
	target_pos = pos + Vector3(
		randf_range(9, 16),
		randf_range(-10, 10),
		randf_range(1.8, 4.2)
	)
	return true

func toggle_ew() -> bool:
	ew_active = not ew_active
	return ew_active

# =============================================================================
# GODOT INTEGRATION
# =============================================================================
func _ready():
	reset()

func reset(new_pos: Vector3 = Vector3(0, 0, 3.5)):
	pos = new_pos
	vel = Vector3.ZERO
	quat = Quaternion.IDENTITY
	omega = Vector3.ZERO
	battery = battery_capacity
	flight_time = 0.0
	score = 0
	target_pos = Vector3(14, 6, 2.8)
	last_engage_time = 0.0
	approach_quality = 1.0
	ew_active = false

func _process(delta: float):
	# Accumulate for fixed physics steps (matches Python game loop)
	physics_accumulator += delta
	while physics_accumulator >= PHYSICS_DT:
		# In real use, input is gathered outside and passed in.
		# For standalone testing, we can leave u as zero here or expose a method.
		physics_accumulator -= PHYSICS_DT

	# Update Godot transform from our state every frame
	global_transform.origin = pos
	global_transform.basis = quat_to_basis(quat)

# Public API for external controllers (Godot scenes / future AI)
func apply_control(throttle: float, roll: float, pitch: float, yaw: float) -> Array[float]:
	var u: Array[float] = get_control(throttle, roll, pitch, yaw)
	step(PHYSICS_DT, u)
	return u

func get_state() -> Dictionary:
	return {
		"pos": pos,
		"vel": vel,
		"quat": quat,
		"omega": omega,
		"battery": battery,
		"score": score,
		"target_pos": target_pos,
		"ew_active": ew_active
	}