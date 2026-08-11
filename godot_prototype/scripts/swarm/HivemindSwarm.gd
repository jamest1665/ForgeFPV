# HivemindSwarm.gd — multi-team autonomous swarm orchestrator
extends Node3D
class_name HivemindSwarm

@export var team_count: int = 2
@export var drones_per_team: int = 8
@export var max_teams: int = 5
@export var max_drones_per_team: int = 100
@export var enable_tangential: bool = false

var managers: Array = []  # SwarmManager
var mode: String = "seek"  # seek | ring | hold
var shared_goal: Vector3 = Vector3(50, 12, 0)

func _ready() -> void:
	team_count = clampi(team_count, 1, max_teams)
	drones_per_team = clampi(drones_per_team, 1, max_drones_per_team)
	_spawn_teams()
	print("HivemindSwarm ready teams=", team_count, " each=", drones_per_team)

func _spawn_teams() -> void:
	clear_all()
	for t in range(team_count):
		var sm := SwarmManager.new()
		sm.name = "Team_%d" % t
		sm.team_id = t
		sm.drone_count = drones_per_team
		sm.spawn_center = Vector3(float(t) * 35.0 - 35.0, 12.0, float(t) * 10.0)
		sm.use_tangential = enable_tangential
		sm.ring_radius = 30.0 + float(t) * 8.0
		add_child(sm)
		# SwarmManager spawns in its own _ready
		managers.append(sm)
	set_mode(mode)

func clear_all() -> void:
	for m in managers:
		if is_instance_valid(m):
			m.queue_free()
	managers.clear()

func set_team_counts(teams: int, per_team: int) -> void:
	team_count = clampi(teams, 1, max_teams)
	drones_per_team = clampi(per_team, 1, max_drones_per_team)
	_spawn_teams()

func set_shared_goal(pos: Vector3) -> void:
	shared_goal = pos
	for m in managers:
		if m is SwarmManager:
			m.set_goal(pos)

func set_mode(m: String) -> void:
	mode = m
	match m:
		"ring":
			for i in range(managers.size()):
				var sm: SwarmManager = managers[i]
				sm.set_tangential_mode(true, sm.spawn_center, sm.ring_radius)
				sm.clear_goal()
		"hold":
			for sm in managers:
				sm.set_tangential_mode(false)
				sm.set_goal(sm.spawn_center)
		_:  # seek
			for sm in managers:
				sm.set_tangential_mode(false)
				sm.set_goal(shared_goal)

func total_alive() -> int:
	var n := 0
	for m in managers:
		if m is SwarmManager:
			n += m.alive_count()
	return n

func get_status() -> Dictionary:
	return {
		"teams": managers.size(),
		"per_team": drones_per_team,
		"alive": total_alive(),
		"mode": mode,
		"goal": shared_goal
	}
