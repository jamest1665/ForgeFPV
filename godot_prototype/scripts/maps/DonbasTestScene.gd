extends Node3D

# Rate-style FPV trainer core for Donbas field
var pos = Vector3(0, 15, 0)
var vel = Vector3.ZERO
var yaw = 0.0
var pitch = 0.0
var roll = 0.0
var throttle = 0.0
var battery = 100.0
var score = 0
var player: Node3D
var cam: Camera3D
var hud: Label
var targets = []
var hit_ids = {}

const MAX_SPEED = 45.0
const ACCEL = 55.0
const DRAG = 1.8
const TURN = 2.4

func _ready():
	_build_world()
	_build_player()
	_build_targets()
	_build_hud()
	print("Donbas training ready")

func _build_world():
	var ground = MeshInstance3D.new()
	var plane = PlaneMesh.new()
	plane.size = Vector2(500, 500)
	ground.mesh = plane
	var mat = StandardMaterial3D.new()
	mat.albedo_color = Color(0.42, 0.36, 0.24)
	ground.material_override = mat
	add_child(ground)
	var light = DirectionalLight3D.new()
	light.light_energy = 1.4
	light.shadow_enabled = true
	light.rotation_degrees = Vector3(-55, 30, 0)
	add_child(light)
	# scattered ruins
	var rng = RandomNumberGenerator.new()
	rng.seed = 42
	for i in range(18):
		var b = MeshInstance3D.new()
		var box = BoxMesh.new()
		var h = rng.randf_range(2.0, 9.0)
		box.size = Vector3(rng.randf_range(3, 8), h, rng.randf_range(3, 8))
		b.mesh = box
		var bm = StandardMaterial3D.new()
		bm.albedo_color = Color(0.45, 0.4, 0.32)
		b.material_override = bm
		var x = rng.randf_range(-180, 180)
		var z = rng.randf_range(-180, 180)
		if Vector2(x, z).length() < 20:
			x += 30
		b.position = Vector3(x, h * 0.5, z)
		add_child(b)

func _build_player():
	player = Node3D.new()
	player.position = pos
	var body = MeshInstance3D.new()
	var box = BoxMesh.new()
	box.size = Vector3(0.55, 0.12, 0.55)
	body.mesh = box
	var mat = StandardMaterial3D.new()
	mat.albedo_color = Color(0.95, 0.55, 0.1)
	body.material_override = mat
	player.add_child(body)
	cam = Camera3D.new()
	cam.current = true
	cam.fov = 100
	cam.position = Vector3(0, 0.08, 0.15)
	player.add_child(cam)
	add_child(player)

func _build_targets():
	var spots = [
		Vector3(40, 1, -30), Vector3(-50, 1, 40), Vector3(80, 1, 60),
		Vector3(-70, 1, -50), Vector3(20, 1, 90), Vector3(-30, 1, -80),
		Vector3(100, 1, -20), Vector3(-90, 1, 10)
	]
	for i in range(spots.size()):
		var t = MeshInstance3D.new()
		var box = BoxMesh.new()
		box.size = Vector3(2.5, 2.0, 2.5)
		t.mesh = box
		var mat = StandardMaterial3D.new()
		mat.albedo_color = Color(0.85, 0.15, 0.1)
		mat.emission_enabled = true
		mat.emission = Color(0.6, 0.05, 0.02)
		mat.emission_energy_multiplier = 0.8
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
	hud.text = "ForgeFPV"
	layer.add_child(hud)
	var help = Label.new()
	help.position = Vector2(16, 680)
	help.add_theme_font_size_override("font_size", 14)
	help.text = "WASD pitch/roll | Q/E yaw | Space/Ctrl throttle | ESC menu | Hit red targets"
	layer.add_child(help)

func _process(delta):
	_read_input(delta)
	_integrate(delta)
	_check_targets()
	_update_hud()
	if Input.is_key_pressed(KEY_ESCAPE):
		get_tree().change_scene_to_file("res://scenes/ui/MainMenu.tscn")

func _read_input(delta):
	var pitch_in = 0.0
	var roll_in = 0.0
	var yaw_in = 0.0
	if Input.is_physical_key_pressed(KEY_W):
		pitch_in -= 1.0
	if Input.is_physical_key_pressed(KEY_S):
		pitch_in += 1.0
	if Input.is_physical_key_pressed(KEY_A):
		roll_in -= 1.0
	if Input.is_physical_key_pressed(KEY_D):
		roll_in += 1.0
	if Input.is_physical_key_pressed(KEY_Q):
		yaw_in -= 1.0
	if Input.is_physical_key_pressed(KEY_E):
		yaw_in += 1.0
	if Input.is_physical_key_pressed(KEY_SPACE):
		throttle = minf(throttle + delta * 1.5, 1.0)
	elif Input.is_physical_key_pressed(KEY_CTRL):
		throttle = maxf(throttle - delta * 1.5, 0.0)
	else:
		throttle = move_toward(throttle, 0.35, delta * 0.4)
	# expo-ish rates
	pitch += pitch_in * TURN * delta * (0.4 + 0.6 * absf(pitch_in))
	roll += roll_in * TURN * delta * (0.4 + 0.6 * absf(roll_in))
	yaw += yaw_in * TURN * 0.85 * delta
	pitch = clampf(pitch, -1.2, 1.2)
	roll = clampf(roll, -1.2, 1.2)

func _integrate(delta):
	# forward from yaw/pitch
	var forward = Vector3(
		-sin(yaw) * cos(pitch),
		sin(pitch),
		-cos(yaw) * cos(pitch)
	).normalized()
	var thrust = throttle * ACCEL
	vel += forward * thrust * delta
	vel.y -= 9.8 * delta * (1.0 - throttle * 0.85)
	vel *= (1.0 - DRAG * delta)
	if vel.length() > MAX_SPEED:
		vel = vel.normalized() * MAX_SPEED
	pos += vel * delta
	if pos.y < 1.0:
		pos.y = 1.0
		vel.y = maxf(vel.y, 0.0)
		vel *= 0.7
	battery = maxf(0.0, battery - throttle * 3.5 * delta)
	if battery <= 0.0:
		throttle = 0.0
		vel *= 0.98
	player.position = pos
	player.rotation = Vector3(pitch, yaw, -roll)

func _check_targets():
	for t in targets:
		if not is_instance_valid(t):
			continue
		var tid = t.get_meta("tid")
		if hit_ids.has(tid):
			continue
		if pos.distance_to(t.position) < 4.0:
			hit_ids[tid] = true
			score += 100
			t.visible = false
			print("Target hit +100 score=", score)

func _update_hud():
	var spd = vel.length()
	hud.text = "SPD %3.0f m/s   ALT %3.0f m   BAT %3.0f%%   SCORE %d   TGT %d/%d" % [
		spd, pos.y, battery, score, hit_ids.size(), targets.size()
	]
