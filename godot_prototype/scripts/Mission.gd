# Mission.gd — training mission definition
class_name Mission
extends Resource

@export var id: String = ""
@export var title: String = ""
@export var description: String = ""
@export var map_id: String = "donbas"
@export var scene_path: String = "res://scenes/maps/DonbasTest.tscn"
@export var scenario_id: String = "target_practice"
@export var target_count: int = 6
@export var time_limit_sec: float = 0.0  # 0 = no limit
@export var min_score: int = 0
@export var difficulty: int = 1  # 1-3
@export var briefing_notes: String = ""

func to_dict() -> Dictionary:
	return {
		"id": id,
		"title": title,
		"description": description,
		"map_id": map_id,
		"scene_path": scene_path,
		"scenario_id": scenario_id,
		"target_count": target_count,
		"time_limit_sec": time_limit_sec,
		"min_score": min_score,
		"difficulty": difficulty,
		"briefing_notes": briefing_notes
	}

static func from_dict(d: Dictionary) -> Mission:
	var m := Mission.new()
	m.id = str(d.get("id", ""))
	m.title = str(d.get("title", ""))
	m.description = str(d.get("description", ""))
	m.map_id = str(d.get("map_id", "donbas"))
	m.scene_path = str(d.get("scene_path", ""))
	m.scenario_id = str(d.get("scenario_id", "target_practice"))
	m.target_count = int(d.get("target_count", 6))
	m.time_limit_sec = float(d.get("time_limit_sec", 0.0))
	m.min_score = int(d.get("min_score", 0))
	m.difficulty = int(d.get("difficulty", 1))
	m.briefing_notes = str(d.get("briefing_notes", ""))
	return m
