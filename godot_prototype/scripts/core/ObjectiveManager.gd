# ObjectiveManager.gd
extends Node
class_name ObjectiveManager

signal all_complete(score: int)
signal objective_progress(hit: int, total: int)

var targets: Array = []
var hit_count: int = 0

func clear() -> void:
	targets.clear()
	hit_count = 0

func add_target(t: Node) -> void:
	targets.append(t)
	if t.has_signal("hit"):
		if not t.hit.is_connected(_on_target_hit):
			t.hit.connect(_on_target_hit)

func spawn_targets(parent: Node, spots: Array) -> void:
	clear()
	for i in range(spots.size()):
		var t = TrainingTarget.spawn(parent, i, spots[i])
		add_target(t)

func check_proximity(player_pos: Vector3) -> void:
	for t in targets:
		if t == null or not is_instance_valid(t):
			continue
		if t.has_method("try_hit"):
			t.try_hit(player_pos)

func _on_target_hit(_id: int, _points: int) -> void:
	hit_count += 1
	objective_progress.emit(hit_count, targets.size())
	if hit_count >= targets.size() and targets.size() > 0:
		all_complete.emit(hit_count)

func get_progress() -> Vector2i:
	return Vector2i(hit_count, targets.size())
