extends Node3D

var player

func _ready():
	print("Donbas ready")
	var ground = MeshInstance3D.new()
	var plane = PlaneMesh.new()
	plane.size = Vector2(400, 400)
	ground.mesh = plane
	var gmat = StandardMaterial3D.new()
	gmat.albedo_color = Color(0.4, 0.35, 0.25)
	ground.material_override = gmat
	add_child(ground)
	var light = DirectionalLight3D.new()
	light.light_energy = 1.5
	light.rotation_degrees = Vector3(-55, 25, 0)
	add_child(light)
	player = Node3D.new()
	player.position = Vector3(0, 12, 0)
	var body = MeshInstance3D.new()
	var box = BoxMesh.new()
	box.size = Vector3(0.6, 0.2, 0.6)
	body.mesh = box
	var bmat = StandardMaterial3D.new()
	bmat.albedo_color = Color(1.0, 0.55, 0.1)
	body.material_override = bmat
	player.add_child(body)
	var cam = Camera3D.new()
	cam.current = true
	cam.fov = 90
	cam.position = Vector3(0, 0.3, 0.4)
	player.add_child(cam)
	add_child(player)
	print("Player spawned - WASD Space Ctrl to fly")

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
