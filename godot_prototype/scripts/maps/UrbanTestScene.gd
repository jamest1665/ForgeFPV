extends Node3D

var player

func _ready():
	print("Urban ready")
	_make_ground()
	_make_light()
	_make_buildings()
	_make_player()

func _make_ground():
	var g = MeshInstance3D.new()
	var p = PlaneMesh.new()
	p.size = Vector2(300, 300)
	g.mesh = p
	var m = StandardMaterial3D.new()
	m.albedo_color = Color(0.22, 0.22, 0.25)
	g.material_override = m
	add_child(g)

func _make_light():
	var l = DirectionalLight3D.new()
	l.light_energy = 1.2
	l.rotation_degrees = Vector3(-45, 20, 0)
	add_child(l)

func _make_buildings():
	var rng = RandomNumberGenerator.new()
	rng.randomize()
	for i in range(30):
		var b = MeshInstance3D.new()
		var box = BoxMesh.new()
		var h = rng.randf_range(8, 30)
		box.size = Vector3(rng.randf_range(4, 10), h, rng.randf_range(4, 10))
		b.mesh = box
		var mat = StandardMaterial3D.new()
		mat.albedo_color = Color(0.3, 0.3, 0.35)
		b.material_override = mat
		var x = rng.randf_range(-120, 120)
		var z = rng.randf_range(-120, 120)
		if Vector2(x, z).length() < 20:
			x += 30
		b.position = Vector3(x, h * 0.5, z)
		add_child(b)

func _make_player():
	player = Node3D.new()
	player.position = Vector3(0, 12, 0)
	var body = MeshInstance3D.new()
	var box = BoxMesh.new()
	box.size = Vector3(0.5, 0.15, 0.5)
	body.mesh = box
	var mat = StandardMaterial3D.new()
	mat.albedo_color = Color(0.2, 0.8, 0.3)
	body.material_override = mat
	player.add_child(body)
	var cam = Camera3D.new()
	cam.current = true
	cam.fov = 90
	cam.position = Vector3(0, 0.2, 0.3)
	player.add_child(cam)
	add_child(player)

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
