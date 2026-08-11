# WindParticleSystem.gd
# ForgeFPV — dust / wind-streak particles driven by WindManager (or manual wind vector)

extends Node3D
class_name WindParticleSystem

@export var enabled: bool = true
@export var max_particles: int = 120
@export var emission_box: Vector3 = Vector3(80, 25, 80)
@export var particle_color: Color = Color(0.75, 0.72, 0.65, 0.35)
@export var follow_player: bool = true

var particles: GPUParticles3D
var wind_mgr: Node = null
var _manual_wind: Vector3 = Vector3(2, 0, 1)
var _player_ref: Node3D = null

func _ready() -> void:
	_build_particles()
	_find_wind_manager()
	print("WindParticleSystem ready")

func _build_particles() -> void:
	particles = GPUParticles3D.new()
	particles.name = "WindParticles"
	particles.amount = max_particles
	particles.lifetime = 2.5
	particles.explosiveness = 0.0
	particles.randomness = 0.6
	particles.visibility_aabb = AABB(-emission_box * 0.5, emission_box)
	particles.local_coords = false

	var mat := ParticleProcessMaterial.new()
	mat.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_BOX
	mat.emission_box_extents = emission_box * 0.5
	mat.direction = Vector3(1, 0, 0)
	mat.spread = 18.0
	mat.initial_velocity_min = 4.0
	mat.initial_velocity_max = 12.0
	mat.gravity = Vector3(0, -0.4, 0)
	mat.damping_min = 0.2
	mat.damping_max = 0.8
	mat.scale_min = 0.05
	mat.scale_max = 0.18
	mat.color = particle_color
	particles.process_material = mat

	var mesh := QuadMesh.new()
	mesh.size = Vector2(0.25, 0.25)
	var draw_mat := StandardMaterial3D.new()
	draw_mat.albedo_color = particle_color
	draw_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	draw_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	draw_mat.billboard_mode = BaseMaterial3D.BILLBOARD_ENABLED
	draw_mat.vertex_color_use_as_albedo = true
	mesh.material = draw_mat
	particles.draw_pass_1 = mesh

	add_child(particles)
	particles.emitting = enabled

func _find_wind_manager() -> void:
	var parent := get_parent()
	if parent and parent.has_node("WindManager"):
		wind_mgr = parent.get_node("WindManager")
		return
	if get_tree().current_scene:
		wind_mgr = get_tree().current_scene.find_child("WindManager", true, false)

func set_wind_manager(wm: Node) -> void:
	wind_mgr = wm

func set_manual_wind(w: Vector3) -> void:
	_manual_wind = w

func set_player(p: Node3D) -> void:
	_player_ref = p

func set_enabled(on: bool) -> void:
	enabled = on
	if particles:
		particles.emitting = on

func _process(_delta: float) -> void:
	if particles == null or not enabled:
		return
	var w := _get_wind()
	var speed := w.length()
	var mat := particles.process_material as ParticleProcessMaterial
	if mat:
		if speed > 0.05:
			mat.direction = w.normalized()
		else:
			mat.direction = Vector3(1, 0, 0)
		mat.initial_velocity_min = 2.0 + speed * 0.8
		mat.initial_velocity_max = 6.0 + speed * 1.6
		# denser particles in stronger wind
		particles.amount = clampi(int(40 + speed * 15.0), 40, max_particles)
	if follow_player and _player_ref and is_instance_valid(_player_ref):
		global_position = _player_ref.global_position + Vector3(0, 2, 0)

elif follow_player == false:
		pass

func _get_wind() -> Vector3:
	if wind_mgr and wind_mgr.has_method("get_wind_at"):
		var origin := global_position
		if _player_ref and is_instance_valid(_player_ref):
			origin = _player_ref.global_position
		return wind_mgr.get_wind_at(origin)
	return _manual_wind

## Optional map-tint helpers
func set_dust_color(c: Color) -> void:
	particle_color = c
	if particles and particles.process_material is ParticleProcessMaterial:
		(particles.process_material as ParticleProcessMaterial).color = c
	if particles and particles.draw_pass_1 is QuadMesh:
		var m := particles.draw_pass_1 as QuadMesh
		if m.material is StandardMaterial3D:
			(m.material as StandardMaterial3D).albedo_color = c

func set_arctic_look() -> void:
	set_dust_color(Color(0.85, 0.9, 0.95, 0.4))

func set_desert_look() -> void:
	set_dust_color(Color(0.75, 0.6, 0.4, 0.4))

func set_urban_look() -> void:
	set_dust_color(Color(0.55, 0.55, 0.58, 0.3))
