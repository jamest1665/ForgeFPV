# SwarmManager.gd — spawn, update, and command a team of SimpleDrones
extends Node3D
class_name SwarmManager

@export var team_id: int = 0
@export var drone_count: int = 8
@export var spawn_center: Vector3 = Vector3(0, 12, 0)
@export var spawn_radius: float = 15.0
@export var use_tangential: bool = false
@export var ring_radius: float = 40.0

var drones: Array = []
var agents: Array = []
var goal: Vector3 = Vector3.ZERO
var has_goal: bool = false
var tangential: TangentialController
var visualizer: TangentVisualizer
var _time: float = 0.0

func _ready() -> void:
	tangential = TangentialController.new()
	tangential.set_ring(spawn_center, ring_radius, spawn_center.y)
	if use_tangential:
		visualizer = TangentVisualizer.new()
		add_child(visualizer)
		visualizer.set_controller(tangential)
	spawn_swarm(drone_count)

func spawn_swarm(count: int) -> void:
	clear_swarm()
	drone_count = count
	var rng := RandomNumberGenerator.new()
	rng.seed = 100 + team_id
	for i in range(count):
		var d := SimpleDrone.new()
		d.name = "Drone_T%d_%d" % [team_id, i]
		SwarmVisuals.apply_team_color(d, team_id)
		var ang := rng.randf() * TAU
		var r := rng.randf() * spawn_radius
		d.position = spawn_center + Vector3(cos(ang) * r, rng.randf_range(-2.0, 2.0), sin(ang) * r)
		add_child(d)
		drones.append(d)
		agents.append(SwarmAgent.new(d))
	print("SwarmManager team ", team_id, " spawned ", count)

func clear_swarm() -> void:
	for d in drones:
		if is_instance_valid(d):
			d.queue_free()
	drones.clear()
	agents.clear()

func set_goal(pos: Vector3) -> void:
	goal = pos
	has_goal = true

func clear_goal() -> void:
	has_goal = false

func set_tangential_mode(on: bool, center: Vector3 = Vector3.ZERO, radius: float = 40.0) -> void:
	use_tangential = on
	if on:
		tangential.set_ring(center, radius, center.y if center.y > 1.0 else 12.0)
		if visualizer == null:
			visualizer = TangentVisualizer.new()
			add_child(visualizer)
		visualizer.set_controller(tangential)
	elif visualizer:
		visualizer.queue_free()
		visualizer = null

func _process(delta: float) -> void:
	_time += delta
	var alive: Array = []
	for d in drones:
		if d is SimpleDrone and d.is_alive():
			alive.append(d)
	for i in range(agents.size()):
		var agent: SwarmAgent = agents[i]
		var d: SimpleDrone = agent.drone
		if d == null or not d.is_alive():
			continue
		var steer := Vector3.ZERO
		if use_tangential:
			var phase := float(i) / maxf(float(drone_count), 1.0) * TAU
			steer = tangential.desired_velocity_for(d.global_position, phase, _time)
		else:
			steer = agent.compute_steering(alive, goal, has_goal)
		d.apply_steering(steer, delta)

func alive_count() -> int:
	var n := 0
	for d in drones:
		if d is SimpleDrone and d.is_alive():
			n += 1
	return n
