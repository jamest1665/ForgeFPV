# HelpOverlay.gd — toggleable in-flight controls help (H key)
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
	panel.size = Vector2(420, 280)
	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 12)
	margin.add_theme_constant_override("margin_right", 12)
	margin.add_theme_constant_override("margin_top", 10)
	margin.add_theme_constant_override("margin_bottom", 10)
	panel.add_child(margin)
	var label := Label.new()
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.add_theme_font_size_override("font_size", 15)
	label.text = "CONTROLS\n\nW/S  Pitch\nA/D  Roll\nQ/E  Yaw\nSpace / Ctrl  Throttle\n\nESC  Pause\nH  Toggle this help\nJ  Toggle EW interference\n\nHit glowing red targets to score."
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
