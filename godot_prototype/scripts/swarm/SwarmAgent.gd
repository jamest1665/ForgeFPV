# SwarmAgent.gd — boids-style behaviors for one SimpleDrone
extends RefCounted
class_name SwarmAgent

var drone: SimpleDrone
var separation_weight: float = 1.4
var alignment_weight: float = 0.8
var cohesion_weight: float = 0.9
var seek_weight: float = 1.2
var separation_radius: float = 8.0
var neighbor_radius: float = 22.0

func _init(d: SimpleDrone = null) -> void:
	drone = d

func compute_steering(neighbors: Array, goal: Vector3, has_goal: bool) -> Vector3:
	if drone == null or not drone.is_alive():
		return Vector3.ZERO
	var sep := Vector3.ZERO
	var ali := Vector3.ZERO
	var coh := Vector3.ZERO
	var count := 0
	var my_pos := drone.global_position
	for n in neighbors:
		if n == drone or not n.is_alive():
			continue
		var other: SimpleDrone = n
		var offset: Vector3 = my_pos - other.global_position
		var dist := offset.length()
		if dist < 0.001:
			continue
		if dist < separation_radius:
			sep += offset.normalized() / dist
		if dist < neighbor_radius:
			ali += other.velocity
			coh += other.global_position
			count += 1
	var steer := Vector3.ZERO
	if sep.length_squared() > 0.0:
		steer += sep.normalized() * separation_weight
	if count > 0:
		ali = (ali / float(count))
		if ali.length_squared() > 0.0:
			steer += ali.normalized() * alignment_weight
		coh = (coh / float(count)) - my_pos
		if coh.length_squared() > 0.0:
			steer += coh.normalized() * cohesion_weight
	if has_goal:
		var to_goal := goal - my_pos
		if to_goal.length_squared() > 0.0:
			steer += to_goal.normalized() * seek_weight
	return steer
