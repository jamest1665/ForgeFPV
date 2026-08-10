# HighScoreManager.gd
extends Node

const SAVE_PATH := "user://forgefpv_scores.cfg"

var scores: Dictionary = {}

func _ready() -> void:
	load_scores()

func load_scores() -> void:
	var cfg := ConfigFile.new()
	if cfg.load(SAVE_PATH) != OK:
		scores = {}
		return
	scores = {}
	for key in cfg.get_section_keys("scores"):
		scores[key] = int(cfg.get_value("scores", key, 0))

func save_scores() -> void:
	var cfg := ConfigFile.new()
	for k in scores.keys():
		cfg.set_value("scores", str(k), scores[k])
	cfg.save(SAVE_PATH)

func submit(map_id: String, score: int) -> bool:
	var prev := int(scores.get(map_id, 0))
	if score > prev:
		scores[map_id] = score
		save_scores()
		return true
	return false

func get_high(map_id: String) -> int:
	return int(scores.get(map_id, 0))
