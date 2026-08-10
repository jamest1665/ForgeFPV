# DebriefSystem.gd — end-of-run summary helper
extends Node
class_name DebriefSystem

var tracking: bool = false
var start_time: float = 0.0
var peak_speed: float = 0.0
var samples: int = 0

func start_tracking() -> void:
	tracking = true
	start_time = Time.get_ticks_msec() / 1000.0
	peak_speed = 0.0
	samples = 0

func update_from_telemetry(t: Dictionary) -> void:
	if not tracking:
		return
	samples += 1
	var spd := float(t.get("speed", 0.0))
	if spd > peak_speed:
		peak_speed = spd

func stop_and_summarize(score: int, hits: int, total: int) -> Dictionary:
	tracking = false
	var elapsed := (Time.get_ticks_msec() / 1000.0) - start_time
	return {
		"score": score,
		"hits": hits,
		"total_targets": total,
		"time_sec": elapsed,
		"peak_speed": peak_speed,
		"samples": samples
	}
