# DonbasTestScene.gd
# Self-contained Donbas training scene

extends Node3D

@export var spawn_player: bool = true

var player_drone: Node3D = null

func _ready() -> void:
	print("DonbasTestScene: Ready")
	_ensure_ground()
	_ensure_light()
	if spawn_player:
		_spawn_player()
	print("DonbasTestScene: Playable")

func _ensure_ground() -> void:
	if has_node("Ground"):
		return
	var ground := MeshInstance3D.new()
	ground.name = "Ground"
	var plane := PlaneMesh.new()
	plane.size = Vector2(500, 500)
	ground.mesh = plane
	var mat := StandardMaterial3D.new()
	mat.albedo_color = Color(0.35, 0.32, 0.22)
	ground.material_override = mat
	add_child(ground)
	var body := StaticBody3D.new()
	var col := CollisionShape3D.new()
	var shape := BoxShape3D.new()
	shape.size = Vector3(500, 1, 500)
	col.shape = shape
	col.position.y = -0.5
	body.add_child(col)
	ground.add_child(body)

func _ensure_light() -> void:
	if has_node("DirectionalLight3D"):
		return
	var light := DirectionalLight3D.new()
	light.name = "DirectionalLight3D"
	light.light_energy = 1.3
	light.shadow_enabled = true
	light.rotation_degrees = Vector3(-50, 20, 0)
	add_child(light)

func _spawn_player() -> void:
	player_drone = Node3D.new()
	player_drone.name = "PlayerDrone"
	player_drone.position = Vector3(0, 8, 0)
	var qpath := "res://godot_prototype/scripts/quadrotor.gd"
	if ResourceLoader.exists(qpath):
		var scr = load(qpath)
		if scr:
			player_drone.set_script(scr)
	var mesh := MeshInstance3D.new()
	var box := BoxMesh.new()
	box.size = Vector3(0.4, 0.12, 0.4)
	mesh.mesh = box
	var mat := StandardMaterial3D.new()
	mat.albedo_color = Color(0.8, 0.55, 0.15)
	mesh.material_override = mat
	player_drone.add_child(mesh)
	var cam := Camera3D.new()
	cam.name = "FPVCamera"
	cam.current = true
	cam.fov = 90.0
	cam.position = Vector3(0, 0.05, 0.1)
	player_drone.add_child(cam)
	add_child(player_drone)
	print("DonbasTestScene: Player spawned")

func _process(delta: float) -> void:
	if player_drone == null or player_drone.has_method("step"):
		return
	var speed := 25.0
	var move := Vector3.ZERO
	if Input.is_key_pressed(KEY_W): move.z -= 1
	if Input.is_key_pressed(KEY_S): move.z += 1
	if Input.is_key_pressed(KEY_A): move.x -= 1
	if Input.is_key_pressed(KEY_D): move.x += 1
	if Input.is_key_pressed(KEY_SPACE): move.y += 1
	if Input.is_key_pressed(KEY_CTRL): move.y -= 1
	if move.length() > 0:
		player_drone.position += move.normalized() * speed * delta
