# ScenarioManager.gd — scenario modifiers for missions
extends Node
class_name ScenarioManager

var current_id: String = "target_practice"
var modifiers: Dictionary = {}

func apply_scenario(id: String) -> void:
	current_id = id
	modifiers = {}
	match id:
		"target_practice":
			modifiers = {"score_mult": 1.0, "wind_mult": 1.0, "label": "Target Practice"}
		"timed_strike":
			modifiers = {"score_mult": 1.25, "wind_mult": 1.0, "label": "Timed Strike"}
		"flanking":
			modifiers = {"score_mult": 1.5, "wind_mult": 1.1, "label": "Flanking Drill"}
		"ring_defense":
			modifiers = {"score_mult": 1.35, "wind_mult": 1.2, "label": "Ring Defense"}
		_:
			modifiers = {"score_mult": 1.0, "wind_mult": 1.0, "label": id}
	print("Scenario applied: ", current_id, " ", modifiers)

func get_score_multiplier() -> float:
	return float(modifiers.get("score_mult", 1.0))

func get_wind_multiplier() -> float:
	return float(modifiers.get("wind_mult", 1.0))

func get_label() -> String:
	return str(modifiers.get("label", current_id))
