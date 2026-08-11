# autonomy_example.gd — demo scene script: player + hivemind swarm
extends Node3D

var hive: HivemindSwarm
var hud: Label

func _ready() -> void:
	_build_ground()
	hive = HivemindSwarm.new()
	hive.name = "Hivemind"
	hive.team_count = 2
	hive.drones_per_team = 10
	hive.enable_tangential = false
	add_child(hive)
	hive.set_shared_goal(Vector3(60, 14, -20))
	hive.set_mode("seek")
	_build_hud()
	print("autonomy_example: hivemind demo running")

func _build_ground() -> void:
	var ground := MeshInstance3D.new()
	var plane := PlaneMesh.new()
	plane.size = Vector2(400, 400)
	ground.mesh = plane
	var mat := StandardMaterial3D.new()
	mat.albedo_color = Color(0.25, 0.28, 0.22)
	ground.material_override = mat
	add_child(ground)
	var light := DirectionalLight3D.new()
	light.light_energy = 1.2
	light.rotation_degrees = Vector3(-50, 25, 0)
	add_child(light)
	var cam := Camera3D.new()
	cam.position = Vector3(0, 40, 80)
	cam.look_at(Vector3(0, 10, 0))
	cam.current = true
	add_child(cam)

func _build_hud() -> void:
	var layer := CanvasLayer.new()
	add_child(layer)
	hud = Label.new()
	hud.position = Vector2(16, 12)
	hud.add_theme_font_size_override("font_size", 16)
	layer.add_child(hud)
	var help := Label.new()
	help.position = Vector2(16, 680)
	help.text = "Autonomy demo · 1=seek 2=ring 3=hold · ESC menu"
	layer.add_child(help)

func _process(_delta: float) -> void:
	if hive and hud:
		var s := hive.get_status()
		hud.text = "HIVEMIND  teams %d  alive %d  mode %s" % [s["teams"], s["alive"], s["mode"]]
	if Input.is_key_pressed(KEY_1):
		hive.set_mode("seek")
	elif Input.is_key_pressed(KEY_2):
		hive.set_mode("ring")
	elif Input.is_key_pressed(KEY_3):
		hive.set_mode("hold")
	if Input.is_key_pressed(KEY_ESCAPE):
		get_tree().change_scene_to_file("res://scenes/ui/MainMenu.tscn")
