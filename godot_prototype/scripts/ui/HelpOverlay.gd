# HelpOverlay.gd — in-flight controls help (H key)
extends CanvasLayer
class_name HelpOverlay

var panel: PanelContainer
var visible_help: bool = false

func _ready() -> void:
	layer = 90
	process_mode = Node.PROCESS_MODE_ALWAYS
	_build()
	hide_help()

func _build() -> void:
	panel = PanelContainer.new()
	panel.position = Vector2(40, 80)
	panel.size = Vector2(460, 320)
	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 12)
	margin.add_theme_constant_override("margin_right", 12)
	margin.add_theme_constant_override("margin_top", 10)
	margin.add_theme_constant_override("margin_bottom", 10)
	panel.add_child(margin)
	var label := Label.new()
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.add_theme_font_size_override("font_size", 14)
	label.text = "CONTROLS\n\nKeyboard\nW/S Pitch · A/D Roll · Q/E Yaw\nSpace / Ctrl Throttle\n\nGamepad / RC (joy 0)\nLeft stick: pitch / roll\nRight stick X: yaw\nRight Y or triggers: throttle\n\nESC Pause · H Help · J EW noise\n\nTune rates in Pilot Settings."
	margin.add_child(label)
	add_child(panel)

func show_help() -> void:
	visible_help = true
	panel.visible = true

func hide_help() -> void:
	visible_help = false
	if panel:
		panel.visible = false

func toggle() -> void:
	if visible_help:
		hide_help()
	else:
		show_help()
