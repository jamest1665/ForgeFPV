# ScoringSystem.gd
extends Node
class_name ScoringSystem

signal score_changed(total: int)
signal target_hit(id: int, points: int, total: int)

var total_score: int = 0
var hits: int = 0
var miss_count: int = 0

func reset() -> void:
	total_score = 0
	hits = 0
	miss_count = 0
	score_changed.emit(total_score)

func add_hit(target_id: int, points: int = 100) -> void:
	hits += 1
	total_score += points
	score_changed.emit(total_score)
	target_hit.emit(target_id, points, total_score)
	print("HIT id=%d +%d total=%d" % [target_id, points, total_score])

func add_miss() -> void:
	miss_count += 1

func get_score() -> int:
	return total_score
