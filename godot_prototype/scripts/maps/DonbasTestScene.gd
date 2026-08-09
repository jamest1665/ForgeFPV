extends Node3D

var player
var cam

func _ready():
	print("Donbas ready")
	_make_ground()
	_make_light()
	_make_player()

func _make_ground():
	var g = MeshInstance3D.new()
	var p = PlaneMesh.new()
	p.size = Vector2(400, 400)
	g.mesh = p
	var m = StandardMaterial3D.new()
	m.albedo_color = Color(0.35, 0.32, 0.22)
	g.material_override = m
	add_child(g)

func _make_light():
	var l = DirectionalLight3D.new()
	l.light_energy = 1.4
	l.rotation_degrees = Vector3(-50, 30, 0)
	add_child(l)

func _make_player():
	player = Node3D.new()
	player.name = "Player"
	player.position = Vector3(0, 10, 0)
	var body = MeshInstance3D.new()
	var box = BoxMesh.new()
	box.size = Vector3(0.5, 0.15, 0.5)
	body.mesh = box
	var mat = StandardMaterial3D.new()
	mat.albedo_color = Color(0.9, 0.5, 0.1)
	body.material_override = mat
	player.add_child(body)
	cam = Camera3D.new()
	cam.current = true
	cam.fov = 90
	cam.position = Vector3(0, 0.2, 0.3)
	player.add_child(cam)
	add_child(player)
	print("Player spawned")

func _process(delta):
	if player == null:
		return
	var speed = 30.0
	var v = Vector3.ZERO
	if Input.is_key_pressed(KEY_W):
		v.z -= 1
	if Input.is_key_pressed(KEY_S):
		v.z += 1
	if Input.is_key_pressed(KEY_A):
		v.x -= 1
	if Input.is_key_pressed(KEY_D):
		v.x += 1
	if Input.is_key_pressed(KEY_SPACE):
		v.y += 1
	if Input.is_key_pressed(KEY_CTRL):
		v.y -= 1
	if v.length() > 0:
		player.position += v.normalized() * speed * delta
