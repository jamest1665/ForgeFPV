# PauseMenu.gd — in-map pause overlay
extends CanvasLayer
class_name PauseMenu

signal resume_pressed
signal restart_pressed
signal main_menu_pressed

var panel: Control
var _built: bool = false

func _ready() -> void:
	layer = 100
	process_mode = Node.PROCESS_MODE_ALWAYS
	visible = false
	_build_ui()

func _build_ui() -> void:
	if _built:
		return
	_built = true
	var dim := ColorRect.new()
	dim.name = "Dim"
	dim.color = Color(0, 0, 0, 0.65)
	dim.set_anchors_preset(Control.PRESET_FULL_RECT)
	dim.mouse_filter = Control.MOUSE_FILTER_STOP
	add_child(dim)

	panel = Control.new()
	panel.name = "Panel"
	panel.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(panel)

	var title := Label.new()
	title.text = "PAUSED"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 32)
	title.position = Vector2(440, 180)
	title.size = Vector2(400, 50)
	panel.add_child(title)

	var btn_resume := _make_btn("Resume", Vector2(440, 280))
	btn_resume.pressed.connect(func(): resume_pressed.emit())
	panel.add_child(btn_resume)

	var btn_restart := _make_btn("Restart Map", Vector2(440, 350))
	btn_restart.pressed.connect(func(): restart_pressed.emit())
	panel.add_child(btn_restart)

	var btn_menu := _make_btn("Main Menu", Vector2(440, 420))
	btn_menu.pressed.connect(func(): main_menu_pressed.emit())
	panel.add_child(btn_menu)

func _make_btn(text: String, pos: Vector2) -> Button:
	var b := Button.new()
	b.text = text
	b.position = pos
	b.size = Vector2(400, 50)
	b.add_theme_font_size_override("font_size", 20)
	return b

func show_pause() -> void:
	visible = true

func hide_pause() -> void:
	visible = false
