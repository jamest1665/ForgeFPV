extends Node3D

var pos = Vector3(0, 14, 0)
var vel = Vector3.ZERO
var yaw = 0.0
var pitch = 0.0
var roll = 0.0
var throttle = 0.0
var battery = 100.0
var score = 0
var player: Node3D
var hud: Label
var targets = []
var hit_ids = {}

const MAX_SPEED = 44.0
const ACCEL = 54.0
const DRAG = 1.9
const TURN = 2.4

func _ready():
	_build_world()
	_build_player()
	_build_targets()
	_build_hud()
	print("Southern Border Big Bend training ready")

func _build_world():
	var ground = MeshInstance3D.new()
	var plane = PlaneMesh.new()
	plane.size = Vector2(480, 480)
	ground.mesh = plane
	var mat = StandardMaterial3D.new()
	mat.albedo_color = Color(0.55, 0.42, 0.28)
	ground.material_override = mat
	add_child(ground)
	var light = DirectionalLight3D.new()
	light.light_energy = 1.5
	light.rotation_degrees = Vector3(-60, 25, 0)
	add_child(light)
	var rng = RandomNumberGenerator.new()
	rng.seed = 33
	for i in range(22):
		var rock = MeshInstance3D.new()
		var box = BoxMesh.new()
		var h = rng.randf_range(3.0, 14.0)
		box.size = Vector3(rng.randf_range(4, 12), h, rng.randf_range(4, 12))
		rock.mesh = box
		var rm = StandardMaterial3D.new()
		rm.albedo_color = Color(0.5, 0.38, 0.28)
		rock.material_override = rm
		rock.position = Vector3(rng.randf_range(-170, 170), h * 0.5, rng.randf_range(-170, 170))
		if Vector2(rock.position.x, rock.position.z).length() < 18:
			rock.position.x += 25
		add_child(rock)

func _build_player():
	player = Node3D.new()
	player.position = pos
	var body = MeshInstance3D.new()
	var box = BoxMesh.new()
	box.size = Vector3(0.55, 0.12, 0.55)
	body.mesh = box
	var mat = StandardMaterial3D.new()
	mat.albedo_color = Color(0.85, 0.45, 0.2)
	body.material_override = mat
	player.add_child(body)
	var cam = Camera3D.new()
	cam.current = true
	cam.fov = 100
	cam.position = Vector3(0, 0.08, 0.15)
	player.add_child(cam)
	add_child(player)

func _build_targets():
	var spots = [Vector3(40, 2, -35), Vector3(-50, 2, 40), Vector3(75, 2, 25), Vector3(-35, 2, -70), Vector3(15, 2, 90), Vector3(-90, 2, 20), Vector3(55, 2, -55)]
	for i in range(spots.size()):
		var t = MeshInstance3D.new()
		var box = BoxMesh.new()
		box.size = Vector3(2.2, 2.0, 2.2)
		t.mesh = box
		var mat = StandardMaterial3D.new()
		mat.albedo_color = Color(0.9, 0.2, 0.1)
		mat.emission_enabled = true
		mat.emission = Color(0.7, 0.1, 0.05)
		t.material_override = mat
		t.position = spots[i]
		t.set_meta("tid", i)
		add_child(t)
		targets.append(t)

func _build_hud():
	var layer = CanvasLayer.new()
	add_child(layer)
	hud = Label.new()
	hud.position = Vector2(16, 12)
	hud.add_theme_font_size_override("font_size", 18)
	layer.add_child(hud)
	var help = Label.new()
	help.position = Vector2(16, 680)
	help.text = "Southern Border Big Bend · canyon terrain · WASD Q/E Space/Ctrl · ESC menu"
	layer.add_child(help)

func _process(delta):
	_fly(delta)
	_check_targets()
	_update_hud()
	if Input.is_key_pressed(KEY_ESCAPE):
		get_tree().change_scene_to_file("res://scenes/ui/MainMenu.tscn")

func _fly(delta):
	var pitch_in = 0.0
	var roll_in = 0.0
	var yaw_in = 0.0
	if Input.is_physical_key_pressed(KEY_W): pitch_in -= 1.0
	if Input.is_physical_key_pressed(KEY_S): pitch_in += 1.0
	if Input.is_physical_key_pressed(KEY_A): roll_in -= 1.0
	if Input.is_physical_key_pressed(KEY_D): roll_in += 1.0
	if Input.is_physical_key_pressed(KEY_Q): yaw_in -= 1.0
	if Input.is_physical_key_pressed(KEY_E): yaw_in += 1.0
	if Input.is_physical_key_pressed(KEY_SPACE): throttle = minf(throttle + delta * 1.5, 1.0)
	elif Input.is_physical_key_pressed(KEY_CTRL): throttle = maxf(throttle - delta * 1.5, 0.0)
	else: throttle = move_toward(throttle, 0.35, delta * 0.4)
	pitch = clampf(pitch + pitch_in * TURN * delta, -1.2, 1.2)
	roll = clampf(roll + roll_in * TURN * delta, -1.2, 1.2)
	yaw += yaw_in * TURN * 0.85 * delta
	var forward = Vector3(-sin(yaw) * cos(pitch), sin(pitch), -cos(yaw) * cos(pitch)).normalized()
	vel += forward * (throttle * ACCEL) * delta
	vel.y -= 9.8 * delta * (1.0 - throttle * 0.85)
	vel *= (1.0 - DRAG * delta)
	if vel.length() > MAX_SPEED: vel = vel.normalized() * MAX_SPEED
	pos += vel * delta
	if pos.y < 1.0:
		pos.y = 1.0
		vel.y = maxf(vel.y, 0.0)
		vel *= 0.7
	battery = maxf(0.0, battery - throttle * 3.5 * delta)
	if battery <= 0.0: throttle = 0.0
	player.position = pos
	player.rotation = Vector3(pitch, yaw, -roll)

func _check_targets():
	for t in targets:
		if not is_instance_valid(t): continue
		var tid = t.get_meta("tid")
		if hit_ids.has(tid): continue
		if pos.distance_to(t.position) < 4.0:
			hit_ids[tid] = true
			score += 100
			t.visible = false

func _update_hud():
	hud.text = "BORDER  SPD %3.0f  ALT %3.0f  BAT %3.0f%%  SCORE %d  TGT %d/%d" % [vel.length(), pos.y, battery, score, hit_ids.size(), targets.size()]
