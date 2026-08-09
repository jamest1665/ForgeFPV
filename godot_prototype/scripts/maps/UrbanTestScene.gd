extends Node3D

var player

func _ready():
	print("Urban ready")
	var ground = MeshInstance3D.new()
	var plane = PlaneMesh.new()
	plane.size = Vector2(300, 300)
	ground.mesh = plane
	var gmat = StandardMaterial3D.new()
	gmat.albedo_color = Color(0.2, 0.2, 0.23)
	ground.material_override = gmat
	add_child(ground)
	var light = DirectionalLight3D.new()
	light.light_energy = 1.3
	light.rotation_degrees = Vector3(-45, 15, 0)
	add_child(light)
	var rng = RandomNumberGenerator.new()
	rng.randomize()
	for i in range(25):
		var b = MeshInstance3D.new()
		var box = BoxMesh.new()
		var h = rng.randf_range(10.0, 28.0)
		box.size = Vector3(rng.randf_range(5.0, 12.0), h, rng.randf_range(5.0, 12.0))
		b.mesh = box
		var mat = StandardMaterial3D.new()
		mat.albedo_color = Color(0.28, 0.28, 0.32)
		b.material_override = mat
		var x = rng.randf_range(-100.0, 100.0)
		var z = rng.randf_range(-100.0, 100.0)
		if Vector2(x, z).length() < 18.0:
			x += 25.0
		b.position = Vector3(x, h * 0.5, z)
		add_child(b)
	player = Node3D.new()
	player.position = Vector3(0, 15, 0)
	var body = MeshInstance3D.new()
	var pbox = BoxMesh.new()
	pbox.size = Vector3(0.6, 0.2, 0.6)
	body.mesh = pbox
	var bmat = StandardMaterial3D.new()
	bmat.albedo_color = Color(0.15, 0.85, 0.35)
	body.material_override = bmat
	player.add_child(body)
	var cam = Camera3D.new()
	cam.current = true
	cam.fov = 90
	cam.position = Vector3(0, 0.3, 0.4)
	player.add_child(cam)
	add_child(player)

func _process(delta):
	if player == null:
		return
	var v = Vector3.ZERO
	if Input.is_physical_key_pressed(KEY_W):
		v.z -= 1.0
	if Input.is_physical_key_pressed(KEY_S):
		v.z += 1.0
	if Input.is_physical_key_pressed(KEY_A):
		v.x -= 1.0
	if Input.is_physical_key_pressed(KEY_D):
		v.x += 1.0
	if Input.is_physical_key_pressed(KEY_SPACE):
		v.y += 1.0
	if Input.is_physical_key_pressed(KEY_CTRL):
		v.y -= 1.0
	if v.length_squared() > 0.0:
		player.position += v.normalized() * 35.0 * delta
