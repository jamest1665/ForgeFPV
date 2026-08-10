# HUD.gd — on-screen telemetry for training flights
extends CanvasLayer
class_name TrainingHUD

var label: Label
var help: Label

func _ready() -> void:
	label = Label.new()
	label.position = Vector2(16, 12)
	label.add_theme_font_size_override("font_size", 18)
	add_child(label)
	help = Label.new()
	help.position = Vector2(16, 680)
	help.add_theme_font_size_override("font_size", 14)
	help.text = "WASD pitch/roll | Q/E yaw | Space/Ctrl throttle | ESC menu | Hit red targets"
	add_child(help)

func update_stats(speed: float, alt: float, battery: float, score: int, hit: int, total: int, map_name: String = "") -> void:
	var prefix := map_name + "  " if map_name != "" else ""
	label.text = "%sSPD %3.0f  ALT %3.0f  BAT %3.0f%%  SCORE %d  TGT %d/%d" % [
		prefix, speed, alt, battery, score, hit, total
	]

func set_help(text: String) -> void:
	help.text = text
