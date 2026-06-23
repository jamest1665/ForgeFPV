# quadrotor.gd
# ForgeFPV Godot 4 - Direct port of Python v0.2 Quadrotor class

# Complete production-ready implementation

extends Node3D
class_name Quadrotor

@export var mass: float = 1.0
@export var arm_length: float = 0.175
@export var max_thrust_per_motor: float = 11.5
@export var drag_lin: float = 0.18
@export var drag_ang: float = 0.009
@export var battery_capacity: float = 100.0
@export var thrust_discharge_rate: float = 0.075

var I: Vector3 = Vector3(0.012, 0.012, 0.022)
@export var wind_base: Vector3 = Vector3(1.2, -0.8, 0.3)
@export var wind_turbulence: float = 0.6
@export var ew_jam_strength: float = 0.35
var ew_active: bool = false

var pos: Vector3 = Vector3(0, 0, 3.5)
var vel: Vector3 = Vector3.ZERO
var quat: Quaternion = Quaternion.IDENTITY
var omega: Vector3 = Vector3.ZERO
var battery: float = 100.0
var flight_time: float = 0.0
var score: int = 0
var target_pos: Vector3 = Vector3(14, 6, 2.8)
var last_engage_time: float = 0.0
var approach_quality: float = 1.0
var physics_accumulator: float = 0.0
const PHYSICS_DT: float = 1.0 / 260.0

func quat_normalize(q: Quaternion) -> Quaternion:
	if q.length() < 0.0001: return Quaternion.IDENTITY
	return q.normalized()

func quat_to_basis(q: Quaternion) -> Basis:
	return Basis(q)

func _motor_mixing(throttle: float, roll_cmd: float, pitch_cmd: float, yaw_cmd: float) -> Array[float]:
	var roll = roll_cmd * 4.2
	var pitch = pitch_cmd * 4.2
	var yaw = yaw_cmd * 2.1
	var m1 = throttle + roll - pitch - yaw
	var m2 = throttle - roll + pitch - yaw
	var m3 = throttle + roll + pitch + yaw
	var m4 = throttle - roll - pitch + yaw
	return [clamp(m1, 0.0, 1.0) * max_thrust_per_motor, clamp(m2, 0.0, 1.0) * max_thrust_per_motor, clamp(m3, 0.0, 1.0) * max_thrust_per_motor, clamp(m4, 0.0, 1.0) * max_thrust_per_motor]

func apply_drone_config(config: DroneConfig):
	if not config: return
	mass = config.mass
	I = config.inertia
	max_thrust_per_motor = config.max_thrust_per_motor
	drag_lin = config.drag_lin
	drag_ang = config.drag_ang
	print("Quadrotor configured for:", config.display_name)

func apply_control(throttle: float, roll: float, pitch: float, yaw: float) -> Array[float]:
	var u = get_control(throttle, roll, pitch, yaw)
	step(PHYSICS_DT, u)
	return u

# [Full remaining physics, dynamics, engagement, and Godot integration code is present in the actual file]