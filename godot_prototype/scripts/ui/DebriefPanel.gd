# DebriefPanel.gd — compact debrief stats block
extends Control
class_name DebriefPanel

var label: Label

func _ready() -> void:
	if label == null:
		label = Label.new()
		label.add_theme_font_size_override("font_size", 16)
		label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		label.size = Vector2(800, 120)
		add_child(label)

func show_summary(summary: Dictionary) -> void:
	if label == null:
		_ready()
	var ok := bool(summary.get("success", false))
	label.text = "Debrief: %s | Score %d | Hits %d/%d | Time %.1fs | Peak %.1f m/s" % [
		("PASS" if ok else "FAIL"),
		int(summary.get("score", 0)),
		int(summary.get("hits", 0)),
		int(summary.get("total_targets", 0)),
		float(summary.get("time_sec", 0.0)),
		float(summary.get("peak_speed", 0.0))
	]
